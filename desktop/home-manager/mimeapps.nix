{ ... }:

let
  officeMS   = "application/vnd.openxmlformats-officedocument";
  officeOpen = "application/vnd.oasis.opendocument";

  LibreOffice = "org.libreoffice.LibreOffice";

  textEditor  = "org.kde.kate.desktop";
  imageViewer = "org.kde.gwenview.desktop";
  audioViewer = "vlc.desktop";
  videoViewer = "vlc.desktop";
  webBrowser  = "librewolf.desktop";

  metaApps = [
    "fr.romainvigier.MetadataCleaner.desktop"
    "org.gnome.Meld.desktop"
    "org.kde.kate.desktop"
    "org.kde.kwrite.desktop"
    "org.kde.okteta.desktop"
  ];
  imageTools = [
    "gimp.desktop"
    "org.kde.gwenview.desktop"
    "org.kde.krita.desktop"
  ];
  audioTools = [
    "org.audacityteam.Audacity.desktop"
    "vlc.desktop"
  ];
  videoTools = [
    "fr.handbrake.ghb.desktop"
    "org.avidemux.Avidemux.desktop"
    "org.kde.kdenlive.desktop"
    "vlc.desktop"
  ];
  webBrowserList = [
    "com.brave.Browser.desktop"
    "com.github.Eloston.UngoogledChromium.desktop"
    "librewolf.desktop"
    "firefox.desktop"
  ];
in
{
  # ~/.config/mimeapps.list
  # https://github.com/nix-community/home-manager/issues/1213
  #xdg.configFile."mimeapps.list".force = true;

  # https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.mimeApps.enable
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";

      "application/json"         = textEditor;
      "application/octet-stream" = textEditor;
      "application/pdf"          = "org.kde.okular.desktop";
      "application/xhtml+xml"    = webBrowser;
      "application/xml"          = textEditor;
      "application/zip"          = "org.kde.ark.desktop";

      "application/x-compressed-tar" = "org.kde.ark.desktop";
      "application/x-executable"     = "org.kde.okteta.desktop";
      "application/x-shellscript"    = textEditor;
      "application/x-zerosize"       = textEditor;

      "${officeMS}.presentationml.presentation" = "${LibreOffice}.impress.desktop";
      "${officeMS}.spreadsheetml.sheet"         = "${LibreOffice}.calc.desktop";
      "${officeMS}.wordprocessingml.document"   = "${LibreOffice}.writer.desktop";

      "${officeOpen}.spreadsheet" = "${LibreOffice}.calc.desktop";

      "text/html"       = webBrowser;
      "text/javascript" = textEditor;
      "text/markdown"   = textEditor;
      "text/plain"      = textEditor;
      "text/x-bibtex"   = "texstudio.desktop";
      "text/x-c++src"   = textEditor;
      "text/x-csrc"     = textEditor;
      "text/x-makefile" = textEditor;
      "text/x-patch"    = "org.gnome.meld.desktop";
      "text/x-python"   = textEditor;
      "text/x-tex"      = "texstudio.desktop";

      "image/gif"     = imageViewer;
      "image/jpeg"    = imageViewer;
      "image/png"     = imageViewer;
      "image/svg+xml" = imageViewer;

      "audio/mp4"        = audioViewer;
      "audio/mpeg"       = audioViewer;
      "audio/vnd.wave"   = audioViewer;
      "audio/x-matroska" = audioViewer;

      "video/mlt-playlist" = "org.kde.kdenlive.desktop";
      "video/mp4"          = videoViewer;
      "video/mpeg"         = videoViewer;
      "video/ogg"          = videoViewer;
      "video/quicktime"    = videoViewer;
      "video/webm"         = videoViewer;
      "video/x-matroska"   = videoViewer;
      "video/x-msvideo"    = videoViewer;

      "x-scheme-handler/geo"    = "openstreetmap-geo-handler.desktop";
      "x-scheme-handler/heroic" = "com.heroicgameslauncher.hgl.desktop";
      "x-scheme-handler/http"   = webBrowser;
      "x-scheme-handler/https"  = webBrowser;
      "x-scheme-handler/mailto" = "thunderbird.desktop";
      "x-scheme-handler/smb"    = "org.kde.dolphin.desktop";
      "x-scheme-handler/steam"  = "com.valvesoftware.Steam.desktop";
      "x-scheme-handler/tel"    = "org.kde.kdeconnect.handler.desktop";
    };

    associations.added = {
      "inode/directory" = [
        "org.kde.dolphin.desktop"
        "org.gnome.Meld.desktop"
      ];

      "application/json" = metaApps;
      "application/octet-stream" = metaApps;
      "application/pdf" = webBrowserList ++ [
        "com.github.jeromerobert.pdfarranger.desktop"
        "com.github.xournalpp.xournalpp.desktop"
        "fr.romainvigier.MetadataCleaner.desktop"
        "io.github.pympress.desktop"
        "org.inkscape.Inkscape.desktop"
        "org.kde.okular.desktop"
      ];
      "application/xhtml+xml" = metaApps ++ webBrowserList;
      "application/xml" = metaApps;
      "application/zip" = metaApps;
      "application/gzip" = metaApps ++ [
        "com.github.xournalpp.xournalpp.desktop"
      ];

      "application/x-compressed-tar" = metaApps;
      "application/x-executable"     = metaApps;
      "application/x-shellscript"    = metaApps;
      "application/x-zerosize"       = metaApps;

      "text/html"       = metaApps ++ webBrowserList;
      "text/javascript" = metaApps;
      "text/markdown"   = metaApps ++ [
        "com.zettlr.Zettlr.desktop"
      ];
      "text/plain"      = metaApps;
      "text/x-c++src"   = metaApps;
      "text/x-csrc"     = metaApps;
      "text/x-makefile" = metaApps;
      "text/x-bibtex"   = metaApps ++ [
        "texstudio.desktop"
      ];
      "text/x-patch"    = metaApps ++ [
        "io.github.mightycreak.Diffuse.desktop"
        "GitKraken.desktop"
      ];
      "text/x-python"   = metaApps;
      "text/x-tex"      = metaApps ++ [
        "texstudio.desktop"
      ];

      "image/gif"     = imageTools;
      "image/jpeg"    = imageTools;
      "image/png"     = imageTools;
      "image/svg+xml" = imageTools;

      "audio/mp4"        = audioTools;
      "audio/mpeg"       = audioTools;
      "audio/vnd.wave"   = audioTools;
      "audio/x-matroska" = audioTools;

      "video/mp4"        = videoTools;
      "video/mpeg"       = videoTools;
      "video/ogg"        = videoTools;
      "video/quicktime"  = videoTools;
      "video/webm"       = videoTools;
      "video/x-matroska" = videoTools;
      "video/x-msvideo"  = videoTools;
    };

    associations.removed = {
    };
  };
}
