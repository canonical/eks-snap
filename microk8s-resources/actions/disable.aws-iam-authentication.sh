#!/usr/bin/env bash

set -e

source $SNAP/actions/common/utils.sh

echo "Disabling AWS IAM authentication"
CLUSTERID="$(echo $RANDOM)"
declare -A map
map[\$CLUSTERID]="$CLUSTERID"
AWS_ENV=""
map[\$AWS_ENV]="$AWS_ENV"
use_manifest aws-iam-authentication delete "$(declare -p map)"
use_manifest aws-iam-authentication-daemon-local delete "$(declare -p map)"

echo "Configuring the API server"
skip_opt_in_config "authentication-token-webhook-config-file" kube-apiserver
restart_service apiserver

rm -rf "${SNAP_DATA}/aws-iam-athenticator" || true

echo "AWS IAM authentication is disabled"
