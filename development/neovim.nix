{ config, pkgs, ...}:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    withPython3 = true;
    configure = {
      customRC = ''
        " tab width
        set tabstop=4
        set shiftwidth=4
        "set expandtab

        " line numbers
        set number
        set cpoptions+=n
        nmap <C-N><C-N> :set invnumber<CR>
        nmap <C-N><C-R> :set invrelativenumber<CR>

        " save key
        nmap <C-S> :saveas %<CR>

        " system clipboard
        vnoremap <C-C> :w !xclip -i -sel c<CR><CR>
        noremap <C-v> :r !xclip -o -sel -c<CR><CR>

        " coloring
        colorscheme elflord
        syntax on

        " color current line of cursor
        set cursorline
        highlight clear CursorLine
        highlight CursorLine cterm=NONE ctermbg=black
        highlight CursorLineNR cterm=NONE ctermfg=white ctermbg=darkred

        " color mark words (through search)
        highlight Search ctermbg=LightYellow ctermfg=Red
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ vim-nix ];
      };
    };
  };
}
