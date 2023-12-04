{ stdenv, lib, buildGoModule, ... }:

let
  system = stdenv.system or stdenv.hostPlatform.system;
in
buildGoModule rec {
  pname = "dev-coder";
  version = "1.0.0";
  src = ../src/dev-coder;
  vendorHash = null;
  subPackages = [ ];
  proxyVendor = true;
}