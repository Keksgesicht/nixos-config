#!/bin/bash

systemctl --user restart \
	pipewire.service \
	pipewire-pulse.service \
	wireplumber.service \
	init-audio.service
