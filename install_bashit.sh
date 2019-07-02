#!/usr/bin/env bash

# Installs Bash-It https://github.com/Bash-it/bash-it

# This isn't meant to work on anything other than CentOS7
# and will probably even break across major versions.

# Pre-Reqs
if ! [ -x "$(command -v git)" ]; then
	echo 'This script requires git. Attempting to install...' >&2
	yum -y install git
fi

echo "========Cloning Bash-It Git Repo========="
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it

echo "==========NOTE!!!!!!!===================="
echo 'Run ~/.bash_it/install.sh to set up Bash-It'
