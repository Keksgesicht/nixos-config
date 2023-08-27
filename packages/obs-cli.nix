{ lib, pkgs, buildGoModule, fetchFromGitHub }:

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=obs-cli
let
  pkgname = "obs-cli";
  pkgver = "0.5.0";
  commit = "7c0b514d6988ba4582f753de829450a96b943301";
in
buildGoModule rec {
  pname = "${pkgname}";
  name = "obs-studio-cli";
  version = "${pkgver}";

  src = fetchFromGitHub {
    #owner = "muesli";
    owner = "yusefnapora";
    repo = "obs-cli";
    rev = "${commit}";
    sha256 = "sha256-Gwv4tN33cYKX4XwyAc5qeruXk+05415/GEFfgkuohV8=";
  };
  vendorHash = "sha256-4pmq234SJZbo7+WljfttOZaIfjY3wIPX9yyCCrzs7P0=";
  proxyVendor = true;

  buildPhase = ''
    local extraflags
    extraflags="-X main.Version=${pkgver} -X main.CommitSHA=${commit}"

    export CGO_CPPFLAGS="$CPPFLAGS"
    export CGO_CFLAGS="$CFLAGS"
    export CGO_CXXFLAGS="$CXXFLAGS"
    export CGO_LDFLAGS="$LDFLAGS"

    cd $src
    go build \
      -trimpath \
      -buildmode=pie \
      -mod=readonly \
      -modcacherw \
      -ldflags "$extraflags -extldflags \"$LDFLAGS\"" \
      -o "../${pkgname}" .
  '';
  installPhase = ''
    cd $src
    install -Dm755 "../${pkgname}" "$out/bin/${pkgname}"
    install -Dm644 "LICENSE"  "$out/share/LICENSE"
  '';

  meta = with lib; {
    description = "OBS-cli is a command-line remote control for OBS";
    license = licenses.mit;
    platforms = platforms.x86_64
             ++ platforms.i686
             ++ platforms.armv7
             ++ platforms.aarch64;
  };
}
