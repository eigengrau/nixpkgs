{ appimageTools, lib, fetchurl }:
let
  pname = "notion-app-enhanced";
  version = "2.0.16-5";
  name = "${pname}-v${version}";

  src = fetchurl {
    url = "https://github.com/notion-enhancer/notion-repackaged/releases/download/v${version}/Notion-Enhanced-${version}.AppImage";
    sha256 = "1v733b4clc9sjgb72fasmbqiyz26d09f3kmvd1nqshwp5d14dajz";
  };

  appimageContents = appimageTools.extract { inherit name src; };
in appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}

    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "Notion Desktop builds with Notion Enhancer for Windows, MacOS and Linux.";
    homepage = "https://github.com/notion-enhancer/desktop";
    license = licenses.unfree;
    maintainers = with maintainers; [ sei40kr ];
    platforms = [ "x86_64-linux" ];
  };
}
