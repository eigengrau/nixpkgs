{ runCommand, xpup, lib, fetchFromGitHub, buildGoPackage }:
buildGoPackage {
  pname = "xpup";
  version = "unstable-20220707";

  src = fetchFromGitHub {
    owner = "ericchiang";
    repo = "xpup";
    rev = "3c408621ad9b5693323acd7d1b455f78444e0c5f";
    sha256 = "sha256-9avyUB4qQUB6tFDSB5qg5bk2C3DiRgsO6o1P/mp+7DY=";
  };

  goPackagePath = "github.com/ericchiang/xpup";

  meta = with lib; {
    description = "A command-line XPath processor";
    homepage = "https://github.com/ericchiang/xpup";
    platforms = platforms.unix;
    license = licenses.asl20;
    maintainers = with maintainers; [ eigengrau ];
  };

  passthru.check = runCommand "run xpup" { } ''
    echo "<foo><bar>hello</bar><quux>world</quux></foo>" \
      | ${xpup}/bin/xpup "/foo/bar" >$out 2>&1
    [[ "$(cat $out | tr -d $'\n ')" = 'hello' ]]
  '';
}
