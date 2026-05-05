#!/usr/bin/env bash

if [ -f /usr/bin/fastfetch ]; then
	fastfetch
fi

#alias lea='ssh user@ip'

eval "$(starship init bash)"

