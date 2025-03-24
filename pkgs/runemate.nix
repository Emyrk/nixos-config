{ pkgs ? import <nixpkgs> {}}:

let
  system = stdenv.system or stdenv.hostPlatform.system;
  # https://www.reddit.com/r/NixOS/comments/1c1lysh/need_help_building_javafx_projects_on_nixos/kz4ehal/
  openjdk = (pkgs.jdk23.override { enableJavaFX = true; });
  fetchurl = pkgs.fetchurl;
  stdenv = pkgs.stdenv;
  lib = pkgs.lib;
  makeWrapper = pkgs.makeWrapper;
  # Libs:
  ## https://index.ros.org/d/libxxf86vm/
  glib = pkgs.glib;
  libXxf86vm = pkgs.xorg.libXxf86vm;
  mesa        = pkgs.mesa;
  gtk3        = pkgs.gtk3;
  openjfx     = pkgs.openjfx;
  xwininfo    = pkgs.xorg.xwininfo;
  xprop       = pkgs.xorg.xprop;
in
stdenv.mkDerivation rec {
  pname = "runemate";
  version = "4.12.2.0";

  # Prevent Nix from unpacking the jar file.
  dontUnpack = true;

  src = fetchurl {
    url = "https://www.runemate.com/download/client?standalone=true&platform=linux&arch=amd64";
    # sha256 = lib.fakeSha256;
    sha256 = "sha256-hJPgP6mdxvj5AzJVtkYiVHUovPgtgdVC9rRZ8V0N6zk=";
  };

  buildInputs = [ openjdk makeWrapper glib libXxf86vm mesa gtk3 openjfx xwininfo xprop];
  sourceRoot = ".";

  installPhase = ''
  mkdir -p $out/bin
  cp $src $out/bin/runemate-client.jar

  # Create a wrapper using makeWrapper that invokes the jar with OpenJDK 17
  makeWrapper ${openjdk}/bin/java $out/bin/runemate-client \
    --add-flags "--add-opens=javafx.graphics/com.sun.javafx.util=ALL-UNNAMED --add-opens=javafx.graphics/com.sun.javafx.tk=ALL-UNNAMED --add-opens=javafx.graphics/com.sun.javafx.css=ALL-UNNAMED -jar $out/bin/runemate-client.jar" \
    --set LD_LIBRARY_PATH "${libXxf86vm}/lib:${glib}/lib:${mesa}/lib:${gtk3}/lib:${openjfx}/lib:$LD_LIBRARY_PATH" \
    --set PATH "${xwininfo}/bin:${xprop}/bin:$PATH"
  '';

  meta = with lib; {
    description = "Runemate Jar File";
    homepage = "https://www.runemate.com/";
    platforms = platforms.linux;
  };
}
