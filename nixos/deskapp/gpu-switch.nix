{ pkgs, config, ... }:

let
  # Keep in sync with ./virt/default.nix
  gpuPci = "10de:2216";
  audioPci = "10de:1aef";

  # GPU switching script
  # Used in qemu hooks defined in `./virt/default.nix`
  gpuSwitch = pkgs.writeShellScriptBin "gpu-switch" ''
    #!/usr/bin/env bash
    set -uo pipefail

    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi

    AWK=${pkgs.gawk}/bin/awk
    LSPCI=${pkgs.pciutils}/bin/lspci
    MODPROBE=${pkgs.kmod}/bin/modprobe
    RMMOD=${pkgs.kmod}/bin/rmmod

    function get_bus() {
        # takes a PCI device identifier (ex: 10de:2216) and returns the bus address (ex: 01:00.0)
        $LSPCI -nn | grep "$1" | $AWK '{print $1}'
    }

    function format_bus() {
        # format bus address 01:00.0 to 0000:01:00.0
        echo "0000:$1"
    }

    function get_bus_driver() {
        # takes a bus address (ex: 0000:01:00.0) and returns the driver in use (ex: nvidia, vfio-pci)
        echo $($LSPCI -nn -s $1 -k | grep "Kernel driver in use" | $AWK '{print $5}')
    }

    function switch_driver() {
        to_driver=$1

        echo "Switching to $to_driver..."

        gpu_bus=$(format_bus $(get_bus "${gpuPci}"))
        audio_bus=$(format_bus $(get_bus "${audioPci}"))

        gpu_driver=$(get_bus_driver $gpu_bus)
        if [ "$gpu_driver" == "$to_driver" ]; then
            echo "GPU already using $to_driver driver"
            exit 0
        fi

        if [ "$gpu_driver" != "" ]; then
            echo "Unbinding GPU from $gpu_driver"
            echo $gpu_bus >/sys/bus/pci/drivers/$gpu_driver/unbind
            echo $audio_bus >/sys/bus/pci/drivers/$gpu_driver/unbind || true
            sleep 5
        fi

        # Force removal, otherwise drivers may not recognize the device (especially if it comes back from windows)
        echo "Removing GPU and audio devices"
        echo "1" > /sys/bus/pci/devices/$gpu_bus/remove || true
        echo "1" > /sys/bus/pci/devices/$audio_bus/remove || true
        sleep 5

        if [ "$to_driver" == "nvidia" ]; then
            echo "Loading nvidia drivers..."
            $MODPROBE -r vfio_pci vfio vfio_iommu_type1
            $MODPROBE -a nvidia nvidia_modeset nvidia_uvm nvidia_drm
            sleep 5
        elif [ "$to_driver" == "vfio-pci" ]; then
            echo "Loading vfio drivers..."
            $RMMOD nvidia_drm # modprobe -r doesn't seem to always work... order is important
            $RMMOD nvidia_uvm
            $RMMOD nvidia_modeset
            $RMMOD nvidia
            $MODPROBE -a vfio_pci vfio vfio_iommu_type1
            sleep 5
        fi

        gpu_driver=$(get_bus_driver $gpu_bus)
        if [ "$gpu_driver" == "$to_driver" ]; then
            echo "Loading drivers bound to $to_driver automatically"
            exit 0
        fi

        echo "Rescanning PCI bus"
        echo "1" > /sys/bus/pci/rescan

        sleep 5

        echo "Binding GPU to $to_driver"
        echo $gpu_bus >/sys/bus/pci/drivers/$to_driver/bind || true
        echo $audio_bus >/sys/bus/pci/drivers/$to_driver/bind || true

        sleep 5
    }

    function nvidia() {
        switch_driver "nvidia"

        # Force drivers to persist, preventing high power usage on idle
        /run/current-system/sw/bin/nvidia-smi -pm 1

        # Restart nvidia-container-toolkit-cdi-generator to pick up new driver
        /run/current-system/sw/bin/systemctl restart nvidia-container-toolkit-cdi-generator.service
    }

    function vfio() {
        switch_driver "vfio-pci"
    }

    function status() {
        gpu_bus=$(format_bus $(get_bus "${gpuPci}"))
        gpu_driver=$(get_bus_driver $gpu_bus)
        echo "$gpu_driver"
    }

    CMD="''${1:-status}"
    shift
    $CMD "$@"
  '';
in
{
  # Enable both nvidia & amd drivers, even if nvidia won't be used for display. This allow
  # installing drivers.
  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];

  # From https://nixos.wiki/wiki/Nvidia
  hardware.nvidia = {
    # Hinders with dynamic switching since it manages the card using KMS
    # https://forums.developer.nvidia.com/t/unbinding-isolating-a-card-is-difficult-post-470/223134
    modesetting.enable = false;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = false;

    nvidiaSettings = false; # no need for settings menu

    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # To test: docker run --rm -it --device=nvidia.com/gpu=all ubuntu:latest nvidia-smi
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    gpuSwitch
  ];

  #   description = "Switch GPU to NVIDIA on boot";
  #   after = [ "libvirtd.service" ];
  #   requires = [ "libvirtd.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${gpuSwitch}/bin/gpu-switch nvidia";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };
}
