#!/usr/bin/env bash

nm-wifi() {
	nmcli radio wifi $@
}

case "$(nm-wifi)" in
"disabled")
	nm-wifi on
;;
"enabled")
	nm-wifi off
;;
esac

exit 0
