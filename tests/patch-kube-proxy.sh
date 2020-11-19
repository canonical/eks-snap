#!/bin/bash

set -ex

echo "--conntrack-max-per-core=0" >> /var/snap/eks/current/args/kube-proxy
systemctl restart snap.eks.daemon-proxy
