{ stdenv, lib, fetchurl, makeWrapper, ... }:

let
  system = stdenv.system or stdenv.hostPlatform.system;
in
stdenv.mkDerivation rec {
  pname = "curseforge";
  src = pkgs.fetchurl {
    url = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.zip";
    sha256 = lib.fakeSha256;
  };

  sourceRoot = ".";

  # installPhase = ''
  #   mkdir -p $out/bin
  #   ls -al
  #   install -Dm755 $pname $out/bin/$pname
  # '';

  meta = with lib; {
    description = "Cursefore AppImage";
    homepage = "https://www.curseforge.com/";
    platforms = platforms.linux;
  };
}
