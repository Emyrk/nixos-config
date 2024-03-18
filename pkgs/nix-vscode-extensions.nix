{ stdenv, lib, fetchurl, makeWrapper, ... }:

# This does not work because it has hard coded paths
# So this nix file is broken atm
let
  system = stdenv.system or stdenv.hostPlatform.system;
in
stdenv.mkDerivation rec {
  pname = "nix-vscode-extensions";
  version = "1.0.0";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/kylecarbs/nixos-config/3ad3bf096ef1d8ee0788cf3157e6005d828702fa/bin/nix-vscode-extensions";
    sha256 = "sha256-8854c5c5df1d981c832715e9fd787c6ec15259b27ba1f03d89e67e3ef5f10fa6";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    ls -al
    install -Dm755 $pname $out/bin/$pname
  '';

  meta = with lib; {
    description = "Kyle's VSCode extension updater for nixos";
    homepage = "https://github.com/kylecarbs/nixos-config";
    platforms = platforms.linux;
  };
}
