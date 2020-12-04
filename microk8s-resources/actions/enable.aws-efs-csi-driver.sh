#!/usr/bin/env bash

set -ex

source $SNAP/actions/common/utils.sh

echo "Enabling EFS driver"

"$SNAP/kubectl" "--kubeconfig=$SNAP_DATA/credentials/client.config" apply -k $SNAP/actions/aws-efs-csi-driver/overlays/stable/
echo "EFS driver is enabled"
