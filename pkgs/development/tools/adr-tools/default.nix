{ stdenv, lib, installShellFiles, makeWrapper, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "adr-tools";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "npryce";
    repo = "adr-tools";
    rev = version;
    sha256 = "sha256-JEwLn+SY6XcaQ9VhN8ARQaZc1zolgAJKfIqPggzV+sU=";
  };

  nativeBuildInputs = [ makeWrapper installShellFiles ];

  dontBuild = true;

  # We don’t install adr-tools’ internal (prefixed with underscore) scripts into
  # the PATH. Since the Bash autocompletion function refers to one of these
  # scripts directly, we need to fix up the call with the absolute path to the
  # script.
  postPatch = ''
    substituteInPlace autocomplete/adr \
       --replace _adr_autocomplete $out/share/adr-tools/_adr_autocomplete
  '';
  # Apart from the main CLI, adr-tools ships some scripts for internal use.
  # These are prefixed with an underscore. Since we don’t need these on the
  # command search path, we only install non-underscored scripts to bin/. Since
  # adr-tools uses “$(dirname $0)” in various places, we prefer wrapper scripts
  # over symlinks.
  installPhase = ''
    runHook preInstall
    libOut=$out/share/adr-tools
    scriptOut=$out/bin
    mkdir -vp $libOut $scriptOut
    cp -va src/* $libOut
    find $libOut -executable -type f -not -name _\* \
      | while read scriptFile; do
          scriptFile=$(realpath $scriptFile)
          scriptName=$(basename $scriptFile)
          printf "exec %s \$@\n" $scriptFile >$out/bin/$scriptName
          chmod 555 $out/bin/$scriptName
        done
    runHook postInstall
  '';
  postInstall = ''
    installShellCompletion --cmd adr --bash autocomplete/adr
  '';

  meta = with lib; {
    homepage = "https://github.com/npryce/adr-tools";
    description =
      "Command-line tools for working with Architecture Decision Records";
    platforms = platforms.all;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ eigengrau ];
  };
}
