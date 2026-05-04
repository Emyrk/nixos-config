{ lib, buildFHSEnv, fetchzip, appimageTools }:

let
  pname = "jetbrains-toolbox";
  version = "3.4.1.78303";

  src = fetchzip {
    url = "https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-${version}.tar.gz";
    hash = "sha256-HFVEjj0wgwvjzmbaSFX82YnC/2oBuj4nPFWFQ9Avb38=";
  };
in
buildFHSEnv {
  inherit pname version;

  multiPkgs =
    pkgs: with pkgs; [
      icu
      libappindicator-gtk3
    ] ++ appimageTools.defaultFhsEnvArgs.multiPkgs pkgs;

  runScript = "${src}/bin/jetbrains-toolbox --update-failed";

  extraInstallCommands = ''
    install -Dm0644 ${src}/bin/jetbrains-toolbox.desktop -t $out/share/applications
    install -Dm0644 ${src}/bin/toolbox-tray-color.png $out/share/pixmaps/jetbrains-toolbox.png
  '';

  meta = {
    description = "JetBrains Toolbox";
    homepage = "https://www.jetbrains.com/toolbox-app";
    license = lib.licenses.unfree;
    mainProgram = "jetbrains-toolbox";
  };
}
