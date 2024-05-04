home-dir:
{ ... }:

{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/calculator" = {
        accuracy = 9;
        angle-units = "degrees";
        base = 10;
        button-mode = "programming";
        number-format = "fixed";
        show-thousands = true;
        show-zeroes = false;
        word-size = 64;
        refresh-interval = 0;
      };
      "org/gnome/meld" = {
        enable-space-drawer = true;
        folder-ignore-symlinks = false;
        folder-shallow-comparison = true;
        highlight-current-line = false;
        highlight-syntax = true;
        indent-width = 4;
        prefer-dark-theme = true;
        show-line-numbers = true;
        style-scheme = "meld-dark";
        wrap-mode = "none";
        # home-manager does not support dconf's tuples
        folder-columns = ''
          [('size', true), ('modification time', true),
           ('permissions', true), ('iso-time', true)]
        '';
        text-filters = ''
          [('CVS/SVN keywords', false, '\\$\\w+(:[^\\n$]+)?\\$'),
           ('C++ comment', true, '//.*'), ('C comment', true, '/\\*.*?\\*/'),
           ('All whitespace', true, '[ \\t\\r\\f\\v]*'),
           ('Leading whitespace', true, '^[ \\t\\r\\f\\v]*'),
           ('Trailing whitespace', true, '[ \\t\\r\\f\\v]*$'),
           ('Script comment', true, '#.*')]
        '';
      };
      "org/gnome/simple-scan" = {
        document-type = "text";
        page-side = "front";
        paper-height = 2970;
        paper-width = 2100;
        photo-dpi = 300;
        text-dpi  = 200;
        prostproc-enabled = false;
        save-directory = "file://${home-dir}/Documents/Office/Scan/";
      };
    };
  };
}
