{ pkgs, lib, ... }:

let
in
{
  home.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  home = {
    username = "gim";
    homeDirectory = "/home/gim";
  };

  programs.home-manager.enable = true;
  home.packages = with pkgs; [
  ];
}
