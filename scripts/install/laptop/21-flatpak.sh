#!/run/current-system/sw/bin/bash

flatpak remote-add --if-not-exists \
	'flathub' \
	https://flathub.org/repo/flathub.flatpakrepo

# essential apps
flatpak install -y \
	com.brave.Browser \
	com.github.Eloston.UngoogledChromium \
	com.github.hluk.copyq \
	com.github.tchx84.Flatseal \
	io.gitlab.librewolf-community \
	org.ferdium.Ferdium \
	org.gnome.Calculator \
	org.kde.okular \
	org.mozilla.firefox \
	org.mozilla.Thunderbird

# nice to have
flatpak install -y \
	com.axosoft.GitKraken \
	com.github.jeromerobert.pdfarranger \
	com.github.xournalpp.xournalpp \
	org.gnome.Firmware \
	org.gnome.meld \
	org.kde.kclock \
	org.kde.kruler \
	org.libreoffice.LibreOffice \
	org.onlyoffice.desktopeditors \
	org.signal.Signal \
	org.texstudio.TeXstudio \
	org.videolan.VLC

# heavy in size
#flatpak install org.freedesktop.Sdk.Extension.texlive
