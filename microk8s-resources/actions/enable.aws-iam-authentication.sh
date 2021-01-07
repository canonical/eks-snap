#!/usr/bin/env bash

set -e

source $SNAP/actions/common/utils.sh

echo "Enabling AWS IAM authentication"

mkdir -p "${SNAP_DATA}/aws-iam-athenticator"
chmod 777 "${SNAP_DATA}/aws-iam-athenticator"
CLUSTERID="$(echo $RANDOM)"
declare -A map
map[\$CLUSTERID]="$CLUSTERID"

# Always set the default region unless we are on AWS
# TODO make default region configurable
AWS_ENV="
        env:
        - name: AWS_REGION
          value: us-east-2
        - name: AWS_DEFAULT_REGION
          value: us-east-2
"
if [ -f /sys/hypervisor/uuid ]
  then
  EC2VM=$(head -c 3 /sys/hypervisor/uuid)
  if [ "$EC2VM" == "ec2" ];
  then
    echo "EC2 node detected"
    AWS_ENV=""
  fi
fi
map[\$AWS_ENV]="$AWS_ENV"

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
refresh_opt_in_config "authentication-token-webhook-config-file" "\${SNAP_DATA}/aws-iam-athenticator/kubeconfig.yaml" kube-apiserver
restart_service apiserver

echo "AWS IAM authentication is enabled"
