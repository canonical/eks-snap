#!/usr/bin/env bash

set -ex

source $SNAP/actions/common/utils.sh

echo "Enabling EFS driver"

"$SNAP/kubectl" "--kubeconfig=$SNAP_DATA/credentials/client.config" apply -k $SNAP_DATA/actions/aws-efs-csi-driver/overlays/stable/
sleep 5
"$SNAP/kubectl" "--kubeconfig=$SNAP_DATA/credentials/client.config" apply -f $SNAP_DATA/actions/aws-efs-csi-driver/setup

echo "EFS driver is enabled"
