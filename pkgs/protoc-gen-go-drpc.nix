{ stdenv, lib, fetchFromGitHub, buildGoModule, ... }:

let
  system = stdenv.system or stdenv.hostPlatform.system;
in
buildGoModule rec {
  pname = "protoc-gen-go-drpc";
  version = "0.0.33";
  src = fetchFromGitHub {
    owner = "storj";
    repo = "drpc";
    rev = "v${version}";
    sha256 = "sha256-mPaQg6bN1I6160RG4Yi3CjKNJ0oHoGYYxOSpOWHWXK0=";
  };
  vendorHash = "sha256-/Fd7cHYhMr9Rx9MdTWkm9utDTFbywChvP2VGDoIRHFo=";
  subPackages = [ "cmd/protoc-gen-go-drpc" ];
  proxyVendor = true;
}