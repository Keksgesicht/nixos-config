{ lib, buildGoModule, fetchFromGitHub }:

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=obs-cli
let
  pkgname = "obs-cli";
  pkgver = "0.5.0";
  commit = "2980d83c681114d6f5d90c924626b92f0b937b6a";
in
buildGoModule {
  pname = "${pkgname}";
  name = "obs-studio-cli";
  version = "${pkgver}";

  src = fetchFromGitHub {
    #owner = "muesli";
    owner = "yusefnapora";
    repo = "obs-cli";
    rev = "${commit}";
    sha256 = "sha256-8hDJAaFH1LV03O3/uegbbWeuUPgP2ZoTxFvnEcTZEGs=";
  };
  vendorHash = "sha256-ur+82ePafm9qHyNPep2xZFGJdc32UJtzJlxuHxhIYt8=";
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
