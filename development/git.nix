{ ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = [ {
      core = {
        fileMode = false;
        #autocrlf = true;
      };
      init = {
        defaultBranch = "main";
      };
      color = {
        ui = true;
        diff = "auto";
        status = "auto";
        branch = "auto";
      };
      alias = {
        reorder = "!GIT_SEQUENCE_EDITOR=\"sed -i -n 'h;1n;2p;g;p'\" git rebase -i HEAD~2";
        lg = ''!f() { \
          git log --all --color --graph --pretty=format:'%C(bold yellow)<sig>%G?</sig>%C(reset) %C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(green)(%cr) %C(blue)<%an>%C(reset)' | \
          sed \
          -e 's#<sig>G</sig>#Good#' \
          -e 's#<sig>B</sig>#\\nBAD \\nBAD \\nBAD \\nBAD \\nBAD#' \
          -e 's#<sig>U</sig>#Unknown#' \
          -e 's#<sig>X</sig>#Expired#' \
          -e 's#<sig>Y</sig>#Expired Key#' \
          -e 's#<sig>R</sig>#Revoked#' \
          -e 's#<sig>E</sig>#Missing Key#' \
          -e 's#<sig>N</sig>#None#' | \
          less -r; \
        }; f'';
        resign = "commit --amend --no-edit -n -S";
        resign-all = "rebase --exec 'git commit --amend --no-edit -n -S' -i";
      };
      push = {
        autoSetupRemote = true;
      };
    } ];
  };
}
