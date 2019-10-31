#!/usr/bin/env bash

# Quick install script for CRI-O on CentOS.
# Must run as root.

echo "========ENABLING KERNEL MODULES========="
modprobe overlay
modprobe br_netfilter

echo "========ADDING SYSCTL CONFIGS========="
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

echo "========ADDING CRI-O YUM REPO========="
yum-config-manager --add-repo=https://cbs.centos.org/repos/paas7-crio-311-candidate/x86_64/os/

echo "========INSTALLING CRI-O========="
yum -y install --nogpgcheck cri-o

echo "========STARTING CRI-O========="
systemctl start crio

