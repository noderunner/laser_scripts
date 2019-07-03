#!/usr/bin/env bash

# This isn't meant to work on anything other than CentOS7
# and will probably even break across major versions.

PIP="/usr/local/bin/pip3.7"

# Pre-Reqs
if ! [ -x "${PIP}" ]; then
	echo "This script requires pip at ${PIP}" >&2
	exit 1
fi

echo "========Installing Powerilne from PIP========="
${PIP} install powerline-status

echo "==========Powerline Install Complete!===================="
