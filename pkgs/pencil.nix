{ lib, appimageTools, fetchurl }:

let
  pname = "pencil";
  version = "1.0.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://5ykymftd1soethh5.public.blob.vercel-storage.com/Pencil-linux-x86_64.AppImage";
    hash = "sha256-tnBoHtwQsF+2/8ksctbJlTRk9XzF3pXcaFMJX+9De24=";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    desktop_dir="$out/share/applications"
    if [ -d "$desktop_dir" ]; then
      desktop_file="$(find "$desktop_dir" -maxdepth 1 -name '*.desktop' -print -quit || true)"
      if [ -n "$desktop_file" ]; then
        substituteInPlace "$desktop_file" \
          --replace-fail 'Exec=AppRun' 'Exec=${pname}' || true
        mv -f "$desktop_file" "$desktop_dir/${pname}.desktop" || true
      fi
    fi
  '';

  meta = {
    description = "Design on canvas. Land in code.";
    homepage = "https://pencil.dev";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
