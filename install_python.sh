#!/usr/bin/env bash

# Compiles and installs a custom Python dev environment
# separate from the rest of the packages on a CentOS7 
# system only.

# This script needs to be run as root and must have
# public internet access to grab the Python tarball.

# This isn't meant to work on anything other than CentOS7
# and will probably even break across major versions.

PYTHON_VERSION="3.7.2"
OFFICIAL_MD5="02a75015f7cd845e27b85192bb0ca4cb"
TEMP_DIR="/tmp/python-${PYTHON_VERSION}-scripted-install"

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

echo "========DOWNLOADING PYTHON ${PYTHON_VERSION}========="
mkdir -p ${TEMP_DIR}; cd ${TEMP_DIR}
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
md5=$(md5sum Python-${PYTHON_VERSION}.tgz |awk '{print $1}')
if [[${OFFICIAL_MD5} -ne ${md5}]]; then
    echo "ERROR: MD5 mismatch!"
    echo "Expected MD5: ${OFFICIAL_MD5}"
    echo "Actual MD5: ${md5}"
    exit 1
fi

echo "========INSTALLING PYTHON ${PYTHON_VERSION}========="
tar xf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}
echo "Compliling with shared libraries into /usr/local/lib"
./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
make && make altinstall

echo "========INSTALLING PIP, SETUPTOOLS, AND WHEEL========="
wget https://bootstrap.pypa.io/get-pip.py
python3.7 get-pip.py

echo "========INSTALL COMPLETE========="
echo "To remove temporary files: rm -rf ${TEMP_DIR}"
