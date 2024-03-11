pkgs: lib: p: n:
let
  lsp-pkgs = with pkgs; [
    clang-tools
    nil
    python3Packages.python-lsp-server
  ];
  lsp-string = lib.strings.concatStringsSep ":" (lib.lists.forEach lsp-pkgs (p:
    "${p}/bin"
  ));

  ide-wrapper = pkgs.writeShellScriptBin "${n}" ''
    export PATH=$PATH:"${lsp-string}"
    exec ${p}/bin/${n} $@
  '';
  ide-merged = pkgs.symlinkJoin {
    pname = "${n}-lsp";
    name = "${n}-with-language-server";
    paths = [
      ide-wrapper
      p
    ];
  };
in
ide-merged
