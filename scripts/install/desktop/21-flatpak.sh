#!/run/current-system/sw/bin/bash

flatpak remote-add --if-not-exists \
	'flathub' \
	https://flathub.org/repo/flathub.flatpakrepo

# essential apps
flatpak install -y 'flathub' \
	com.github.hluk.copyq \
	com.github.tchx84.Flatseal

# browser
flatpak install -y 'flathub' \
	com.brave.Browser \
	com.github.Eloston.UngoogledChromium \
	com.github.micahflee.torbrowser-launcher \
	io.gitlab.librewolf-community \
	org.ferdium.Ferdium \
	org.mozilla.firefox \
	org.signal.Signal

# office
flatpak install -y 'flathub' \
	com.github.jeromerobert.pdfarranger \
	com.github.xournalpp.xournalpp \
	com.zettlr.Zettlr \
	net.jami.Jami \
	org.kde.kclock \
	org.kde.okular \
	org.libreoffice.LibreOffice \
	org.mozilla.Thunderbird \
	org.onlyoffice.desktopeditors \
	org.videolan.VLC

# hardware
flatpak install -y 'flathub' \
	org.gnome.Firmware

# miscs
flatpak install -y 'flathub' \
	com.belmoussaoui.Decoder \
	com.jgraph.drawio.desktop \
	fr.romainvigier.MetadataCleaner \
	io.github.seadve.Mousai \
	org.fedoraproject.MediaWriter \
	org.gimp.GIMP \
	org.inkscape.Inkscape \
	org.kde.kdenlive

# development
flatpak install -y 'flathub' \
	com.axosoft.GitKraken \
	com.visualstudio.code \
	dev.lapce.lapce \
	org.kde.okteta \
	org.texstudio.TeXstudio \
	pm.mirko.Atoms

# gaming
flatpak install -y 'flathub' \
	com.github.Matoking.protontricks \
	com.heroicgameslauncher.hgl \
	com.obsproject.Studio \
	com.valvesoftware.Steam \
	net.davidotek.pupgui2 \
	net.lutris.Lutris \
	org.prismlauncher.PrismLauncher

# gaming
flatpak install -y 'flathub' \
	org.freedesktop.Platform.VulkanLayer.MangoHud \
	org.freedesktop.Platform.VulkanLayer.vkBasalt \
	org.freedesktop.Platform.VulkanLayer.gamescope

# heavy in size
flatpak install -y 'flathub' \
	org.freedesktop.Sdk.Extension.texlive
