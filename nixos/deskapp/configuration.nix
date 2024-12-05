{ pkgs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./ha-ctrl.nix
    ./virt
    ./home-backup.nix
    ./vms-backup.nix
    ../common.nix
    ../network_bridge.nix
    ../dev.nix
    ../docker.nix
    ../ups.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    # Prevent intel nic from dropping after 1h
    # See https://www.reddit.com/r/buildapc/comments/xypn1m/network_card_intel_ethernet_controller_i225v_igc/
    "pcie_port_pm=off"
    "pcie_aspm.policy=performance"
  ];


  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

  # From https://nixos.wiki/wiki/Nvidia
  hardware.nvidia = {
    # Hinders with dynamic switching since it manages the card using KMS
    # https://forums.developer.nvidia.com/t/unbinding-isolating-a-card-is-difficult-post-470/223134
    modesetting.enable = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false; # no need for settings menu
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # To test: docker run --rm -it --device=nvidia.com/gpu=all ubuntu:latest nvidia-smi
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];


  networking.hostName = "deskapp";

  # Drives (lsblk -f)
  fileSystems."/mnt/secondary" = {
    device = "/dev/disk/by-uuid/e154b94d-9f7e-4079-a80b-659e6ab532ca";
    fsType = "ext4";
  };
  fileSystems."/mnt/tertiary" = {
    device = "/dev/disk/by-uuid/1bece886-d8b2-4fd4-a057-990de4ba308c";
    fsType = "ext4";
  };
  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024; # 16GB
  }];

  # Networking
  networking.networkmanager.enable = true;
  networking.myBridge = {
    enable = true;
    interface = "eno1";
    lanIp = "192.168.0.30";
  };
  networking.hosts = {
    "100.109.193.77" = [ "localhost.humanfirst.ai" ];
  };

  # Display
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "appaquet";
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Install firefox
  programs.firefox.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.printing.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
}
