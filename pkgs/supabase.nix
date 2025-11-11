{ stdenv, lib, fetchurl, makeWrapper, ... }:

let
  system = stdenv.system or stdenv.hostPlatform.system;
in
stdenv.mkDerivation rec {
  pname = "supabase";
  version = "2.58.6";

  src = fetchurl {
    url = "https://github.com/supabase/cli/releases/download/v${version}/supabase_linux_${{
      "x86_64-linux"  = "amd64";
      "aarch64-linux" = "arm64";
    }.${system}}.tar.gz";
    sha256 = {
      "x86_64-linux" = "sha256-u0C9SqYSaclF+ZEOny+p4X1HGUeSUGR83qaNJlqNbyc=";
      "aarch64-linux" = "sha256-fIpWNQLAThw2001F2DrYJ/oKuaoGKxwftiMWtKOKpxM="; # not the real hash
    }.${system};
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    ls -al
    install -Dm755 $pname $out/bin/$pname
  '';

  meta = with lib; {
    description = "A CLI interface for Supabase";
    homepage = "https://github.com/supabase/cli/";
    platforms = platforms.linux;
  };
}