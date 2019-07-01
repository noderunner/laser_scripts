#!/usr/bin/env bash

# Compiles and installs a custom Python dev environment
# separate from the rest of the packages on a CentOS7 
# system only.

# This script needs to be run as root and must have
# public internet access to grab the Python tarball.

# This isn't meant to work on anything other than CentOS7
# and will probably even break across major versions.

PYTHON_VERSION="3.7.2"
PYTHON_BINARY="python3.7"
PIP_BINARY="pip3.7"
OFFICIAL_MD5="02a75015f7cd845e27b85192bb0ca4cb"
TEMP_DIR="/tmp/python-$PYTHON_VERSION-scripted-install"

# Install pre-requisite tools
echo "========INSTALLING PREREQUISITE PACKAGES========="
yum -y update
yum -y groupinstall "development tools"
# These are needed for compilation of all Python features.
yum -y install zlib-devel bzip2-devel \
    openssl-devel ncurses-devel \
    sqlite-devel readline-devel \
    tk-devel gdbm-devel db4-devel \
    libpcap-devel xz-devel expat-devel \
    libffi-devel
# Make sure we can download Python
yum -y install wget

echo "========DOWNLOADING PYTHON $PYTHON_VERSION========="
mkdir -p $TEMP_DIR; cd $TEMP_DIR
wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
md5=$(md5sum Python-$PYTHON_VERSION.tgz |awk 'print $1')
if [[$OFFICIAL_MD5 -ne $md5]]; then
    echo "ERROR: MD5 mismatch!"
    echo "Expected MD5: $OFFICIAL_MD5"
    echo "Actual MD5: $md5"
    exit 1
fi

echo "========INSTALLING PYTHON $PYTHON_VERSION========="
tar xf Python-$PYTHON_VERSION.tgz
cd Python-$PYTHON_VERSION
echo "Compliling with shared libraries into /usr/local/lib"
./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
make && make altinstall

echo "========INSTALLING PIP, SETUPTOOLS, AND WHEEL========="
wget https://bootstrap.pypa.io/get-pip.py
python3.7 get-pip.py

echo "========DEFAULTING TO NEW PYTHON========="
alternatives --install /usr/bin/python python /usr/bin/python2 50
alternatives --install /usr/bin/python python /usr/local/bin/$PYTHON_BINARY 100
alternatives --install /usr/bin/pip pip /usr/local/bin/$PIP_BINARY 50

echo "========UPDATING PIP========="
# CentOS 6/7 has an annoying feature where /usr/local/bin is hardcoded into the bash
# binary $PATH BEFORE /usr/bin, and /bin, meaning that the exising /usr/local/bin/pip
# will take precedence in the PATH before /usr/bin/pip, rendering alternatives moot.
# To work around this, I just rename the binary for the old pip, which of course will
# break that RPM.
mv /usr/local/bin/pip /usr/local/bin/pip.old
/usr/local/bin/$PIP_BINARY install --upgrade pip

echo "========INSTALL COMPLETE========="
echo "To remove temporary files: rm -rf $TEMP_DIR"
#!/usr/bin/env bash

# Compiles and installs the latest version of vim
# and sets up a lot of my personal plugins and
# options.

# This is intended for CentOS7 systems to provide
# a more modern version of vim with features compiled
# in that make it better suited as a development IDE.

# Must be run as root

GIT_BASE_DIR="$HOME/git/"

echo "========INSTALLING PREREQUISITE PACKAGES========="
yum -y update
yum -y groupinstall "development tools"
yum -y install gcc-c++ ncurses-devel python-devel git

echo "========REMOVING VIM RPMS========="
# yum -y remove vim-filesystem vim-minimal vim-common vim-enhanced

echo "========CLONING VIM GIT REPO========="
if [[ ! -d $GIT_BASE_DIR ]]; then
    mkdir -p $GIT_BASE_DIR
fi
cd $GIT_BASE_DIR
git clone https://github.com/vim/vim.git

echo "========BUILDING VIM========="
cd $GIT_BASE_DIR/vim/
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
#!/usr/bin/env bash

# Installs GoLang

# This isn't meant to work on anything other than CentOS7
# and will probably even break across major versions.

GOLANG_TARBALL="go1.12.1.linux-amd64.tar.gz"
GOLANG_URL="https://dl.google.com/go/"
OFFICIAL_SHA256="2a3fdabf665496a0db5f41ec6af7a9b15a49fbe71a85a50ca38b1f13a103aeec"
TEMP_DIR="/tmp/golang-scripted-install"

echo "========INSTALLING PREREQUISITES========="
yum -y install curl perl-Digest-SHA

echo "========DOWNLOADING $GOLANG_TARBALL========="
mkdir -p $TEMP_DIR; cd $TEMP_DIR
curl -LO "$GOLANG_URL/$GOLANG_TARBALL"
checksum=$(shasum -a 256 $GOLANG_TARBALL |awk 'print $1')
if [[$OFFICIAL_SHA256 -ne $checksum]]; then
    echo "ERROR: SHA256 mismatch!"
    echo "Expected: $OFFICIAL_SHA256"
    echo "Actual: $checksum"
    exit 1
fi

echo "========INSTALLING $GOLANG_VERSION========="
tar -C /usr/local -xvzf $GOLANG_TARBALL

echo "========SETTING GLOBAL PATH========="
echo "export PATH=$PATH:/usr/local/go/bin" > /etc/profile.d/golang.sh
export PATH=$PATH:/usr/local/go/bin

echo "========INSTALL COMPLETE========="
go version
echo "To remove temporary files: rm -rf $TEMP_DIR"
#!/usr/bin/env bash

# Quick install script for Docker on CentOS.
# Must run as root.

echo "========INSTALLING PREREQUISITE PACKAGES========="
yum -y install yum-utils device-mapper-persistent-data lvm2

echo "========ADDING DOCKER YUM REPO========="
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "========INSTALLING DOCKER PACKAGES========="
yum -y install docker-ce docker-ce-cli containerd.io

echo "========ENABLING SERVICES========="
systemctl enable docker
systemctl start docker

echo "========ADDING MSTEVENSON TO DOCKER GROUP========="
usermod -aG docker mstevenson

