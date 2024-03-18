#!/run/current-system/sw/bin/bash

flatpak remote-add --if-not-exists \
	'flathub' \
	https://flathub.org/repo/flathub.flatpakrepo

# essential apps
flatpak install -y 'flathub' \
	com.github.tchx84.Flatseal

# browser
flatpak install -y 'flathub' \
	com.github.micahflee.torbrowser-launcher \

# office
flatpak install -y 'flathub' \
	com.zettlr.Zettlr \
	org.kde.kclock \
	org.onlyoffice.desktopeditors \

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

# development
flatpak install -y 'flathub' \
	com.visualstudio.code \
	dev.lapce.lapce \
	pm.mirko.Atoms

# gaming
flatpak install -y 'flathub' \
	com.github.Matoking.protontricks \
	com.heroicgameslauncher.hgl \
	com.valvesoftware.Steam \
	net.davidotek.pupgui2 \
	net.lutris.Lutris \
	org.prismlauncher.PrismLauncher

# gaming
flatpak install -y 'flathub' \
	org.freedesktop.Platform.VulkanLayer.MangoHud \
	org.freedesktop.Platform.VulkanLayer.vkBasalt \
	org.freedesktop.Platform.VulkanLayer.gamescope
