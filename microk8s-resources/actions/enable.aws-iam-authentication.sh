#!/usr/bin/env bash

set -e

source $SNAP/actions/common/utils.sh

echo "Enabling AWS IAM authentication"

mkdir -p "${SNAP_DATA}/aws-iam-athenticator"
chmod 777 "${SNAP_DATA}/aws-iam-athenticator"
CLUSTERID="$(echo $RANDOM)"
declare -A map
map[\$CLUSTERID]="$CLUSTERID"
use_manifest aws-iam-authentication apply "$(declare -p map)"
echo "Waiting for the authenticator service to start"
sleep 5
"$SNAP/kubectl" "--kubeconfig=$SNAP_DATA/credentials/client.config" -n kube-system rollout status ds/aws-iam-authenticator

echo "Configuring the API server"
until [ -f "${SNAP_DATA}/aws-iam-athenticator/kubeconfig.yaml" ]
do
     sleep 5
     echo "Waiting for kubeconfig file to appear."
done
refresh_opt_in_config "authentication-token-webhook-config-file" "${SNAP_DATA}/aws-iam-athenticator/kubeconfig.yaml" kube-apiserver
restart_service apiserver

echo "AWS IAM authentication is enabled"
