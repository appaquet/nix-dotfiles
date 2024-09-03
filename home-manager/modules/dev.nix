{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tokei

    dive # docker container explorer
    lazydocker # top like app for docker

    protobuf
    capnproto
    flatbuffers

    mold-wrapped

    gnumake
    bintools # ld, objdump, etc.
  ];
}

