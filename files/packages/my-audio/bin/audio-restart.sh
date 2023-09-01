#!/bin/bash

systemctl --user restart \
	pipewire.service \
	pipewire-pulse.service \
	wireplumber.service \
	my-audio.service
