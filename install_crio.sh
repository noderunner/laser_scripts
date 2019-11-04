#!/usr/bin/env bash

# Quick install script for CRI-O on CentOS.
# Must run as root.

echo "========ENABLING KERNEL MODULES========="
modprobe overlay
modprobe br_netfilter
echo "Done."

echo "========ADDING SYSCTL CONFIGS========="
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
echo "Done."

echo "========ADDING CRI-O YUM REPO========="
yum-config-manager --add-repo=https://cbs.centos.org/repos/paas7-crio-311-candidate/x86_64/os/
echo "Done."

echo "========INSTALLING CRI-O========="
yum -y install --nogpgcheck cri-o
echo "Done."

echo "========STARTING CRI-O========="
systemctl start crio
echo "Done."

echo "========ADDING K8S YUM REPO========="
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
echo "Done."

echo "========INSTALLING K8S PACKAGES========="
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet
echo "Done."

echo "========DISABLING SELINUX========="
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
echo "Done."

echo "========DISABLING SWAP========="
/usr/sbin/swapoff -a
sed -i '/swap/d' /etc/fstab
echo "Done."

echo "========DISABLING FIREWALLD========="
systemctl stop firewalld
systemctl disable firewalld
echo "Done."

echo "========CONFIGURING KUBELET ARGS========="
mkdir -p /etc/default
cat > /etc/default/kubelet <<EOF
KUBELET_EXTRA_ARGS=--container-runtime=remote --cgroup-driver=systemd --container-runtime-endpoint=unix:///var/run/crio/crio.sock --image-service-endpoint=unix:///var/run/crio/crio.sock --runtime-request-timeout=10m
EOF
echo "Done."
