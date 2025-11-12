{ lib, appimageTools, fetchurl }:

let
  pname = "cmux";
  version = "0.5.1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/coder/cmux/releases/download/v${version}/cmux-${version}-x86_64.AppImage";
    hash = "sha256-nXfqBOxDRtkABS9eAH9EXg2mraauNraWE3tvWMGt24g=";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # optional: use contents if you want to install icons/desktop from the AppImage
  # extraInstallCommands can tweak the generated desktop entry
  extraInstallCommands = ''
    desktop_dir="$out/share/applications"
    if [ -d "$desktop_dir" ]; then
      desktop_file="$(find "$desktop_dir" -maxdepth 1 -name '*.desktop' -print -quit || true)"
      if [ -n "$desktop_file" ]; then
        substituteInPlace "$desktop_file" \
          --replace-fail 'Exec=AppRun' 'Exec=${pname}' || true
        # Normalize the filename
        mv -f "$desktop_file" "$desktop_dir/${pname}.desktop" || true
      fi
    fi
  '';

  meta = {
    description = "AI agent multiplexer";
    homepage = "https://github.com/coder/cmux";
    downloadPage = "https://github.com/coder/cmux/releases";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
