#!/usr/bin/env bash

# Compiles and installs the latest version of vim
# and sets up a lot of my personal plugins and
# options.

# This is intended for CentOS7 systems to provide
# a more modern version of vim with features compiled
# in that make it better suited as a development IDE.

# Must be run as root

GIT_BASE_DIR="${HOME}/git/"

echo "========INSTALLING PREREQUISITE PACKAGES========="
yum -y update
yum -y groupinstall "development tools"
yum -y install gcc-c++ ncurses-devel python-devel git

echo "========REMOVING VIM RPMS========="
# yum -y remove vim-filesystem vim-minimal vim-common vim-enhanced

echo "========CLONING VIM GIT REPO========="
if [[ ! -d ${GIT_BASE_DIR} ]]; then
    mkdir -p ${GIT_BASE_DIR}
fi
cd ${GIT_BASE_DIR}
git clone https://github.com/vim/vim.git

echo "========BUILDING VIM========="
cd ${GIT_BASE_DIR}/vim/
./configure \
    --enable-python3interp=yes \
    --enable-pythoninterp=yes \
    --with-python-config-dir=/usr/local/lib/python3.7/config-3.7m-x86_64-linux-gnu/ \
    --with-python-config-dir=/lib64/python2.7/config \
    --enable-multibyte \
    --enable-gui=no \
    --enable-rubyinterp \
    --with-features=huge \
    --enable-cscope \
    --prefix=/usr/local
make VIMRUNTIMEDIR=/usr/local/share/vim/vim81 && make install

echo "========CONFIGURING GOBAL PATHS AND ALIASES========="
update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
update-alternatives --set editor /usr/local/bin/vim
update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
update-alternatives --set vi /usr/local/bin/vim
update-alternatives --install /usr/bin/vim vim /usr/local/bin/vim 1
update-alternatives --set vim /usr/local/bin/vim

echo "========INSTALL COMPLETE========="
vim --version
