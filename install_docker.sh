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

