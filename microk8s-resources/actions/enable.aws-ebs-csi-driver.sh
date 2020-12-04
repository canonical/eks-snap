#!/usr/bin/env bash

set -ex

source $SNAP/actions/common/utils.sh

echo "Enabling EBS driver"

"$SNAP/kubectl" "--kubeconfig=$SNAP_DATA/credentials/client.config" apply -f $SNAP_DATA/actions/aws-ebs-csi-driver/secret.yaml
sleep 3
"$SNAP/kubectl" "--kubeconfig=$SNAP_DATA/credentials/client.config" apply -k $SNAP_DATA/actions/aws-ebs-csi-driver/overlays/stable/
sleep 5
sleep 5
"$SNAP/kubectl" "--kubeconfig=$SNAP_DATA/credentials/client.config" apply -f $SNAP_DATA/actions/aws-ebs-csi-driver/setup

echo "EBS driver is enabled"
