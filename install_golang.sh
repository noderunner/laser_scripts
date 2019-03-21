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

echo "========DOWNLOADING ${GOLANG_TARBALL}========="
mkdir -p ${TEMP_DIR}; cd ${TEMP_DIR}
curl -LO "${GOLANG_URL}/${GOLANG_TARBALL}"
checksum=$(shasum -a 256 ${GOLANG_TARBALL} |awk '{print $1}')
if [[${OFFICIAL_SHA256} -ne ${checksum}]]; then
    echo "ERROR: SHA256 mismatch!"
    echo "Expected: ${OFFICIAL_SHA256}"
    echo "Actual: ${checksum}"
    exit 1
fi

echo "========INSTALLING ${GOLANG_VERSION}========="
tar -C /usr/local -xvzf ${GOLANG_TARBALL}

echo "========SETTING GLOBAL PATH========="
echo "export PATH=$PATH:/usr/local/go/bin" > /etc/profile.d/golang.sh
export PATH=$PATH:/usr/local/go/bin

echo "========INSTALL COMPLETE========="
go version
echo "To remove temporary files: rm -rf ${TEMP_DIR}"
