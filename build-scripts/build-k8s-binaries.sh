#!/bin/bash
set -eux

echo "Building k8s binaries from $KUBERNETES_REPOSITORY tag $KUBERNETES_TAG"
build_apps="kube-apiserver"
fetch_apps="kubectl kube-controller-manager kube-scheduler kubelet kube-proxy"
build_path_apps="cmd/kube-apiserver"
fetch_path_apps="cmd/kubectl cmd/kube-controller-manager cmd/kube-scheduler cmd/kubelet cmd/kube-proxy"
export KUBE_SNAP_BINS="build/kube_bins/$KUBE_VERSION"
mkdir -p $KUBE_SNAP_BINS/$KUBE_ARCH
echo $KUBE_VERSION > $KUBE_SNAP_BINS/version

# Build the apiserver
export GOPATH=$SNAPCRAFT_PART_BUILD/go

rm -rf $GOPATH
mkdir -p $GOPATH

git clone --depth 1 https://github.com/kubernetes/kubernetes $GOPATH/src/github.com/kubernetes/kubernetes/ -b $KUBERNETES_TAG

(cd $GOPATH/src/$KUBERNETES_REPOSITORY
  git config user.email "microk8s-builder-bot@ubuntu.com"
  git config user.name "MicroK8s builder bot"

  PATCHES="patches"
  if echo "$KUBE_VERSION" | grep -e beta -e rc -e alpha
  then
    PATCHES="pre-patches"
  fi

  for patch in "${SNAPCRAFT_PROJECT_DIR}"/build-scripts/"$PATCHES"/*.patch
  do
    echo "Applying patch $patch"
    git am < "$patch"
  done

  rm -rf $GOPATH/src/$KUBERNETES_REPOSITORY/_output/
  make clean
  for app in ${build_path_apps}
  do
    if [ "$app" = "cmd/kube-apiserver" ]
    then
      make WHAT="${app}" GOFLAGS=-tags=libsqlite3,dqlite CGO_CFLAGS="-I${SNAPCRAFT_STAGE}/usr/include/" CGO_LDFLAGS="-L${SNAPCRAFT_STAGE}/lib" KUBE_CGO_OVERRIDES=kube-apiserver
    else
      make WHAT="${app}"
    fi
  done
)
for app in $build_apps; do
  cp $GOPATH/src/$KUBERNETES_REPOSITORY/_output/bin/$app $KUBE_SNAP_BINS/$KUBE_ARCH/
done

rm -rf $GOPATH/src/$KUBERNETES_REPOSITORY/_output/

# Download eks k8s binaries
rm -rf eks-d-tmp/
mkdir eks-d-tmp/
(cd eks-d-tmp/
  wget $EKS_REPO/$EKS_SPEC -O spec.yaml
  K8S_SRV=$(grep -e "artifacts.*kubernetes-server-linux-$ARCH.tar.gz" spec.yaml | awk '{print $2}')
  K8S_NODE=$(grep -e "artifacts.*kubernetes-server-linux-$ARCH.tar.gz" spec.yaml | awk '{print $2}')
  K8S_CLIENT=$(grep -e "artifacts.*kubernetes-client-linux-$ARCH.tar.gz" spec.yaml | awk '{print $2}')

  wget $K8S_SRV -O srv.tar.gz
  wget $K8S_NODE -O node.tar.gz
  wget $K8S_CLIENT -O client.tar.gz

  tar -zxvf srv.tar.gz
  tar -zxvf node.tar.gz
  tar -zxvf client.tar.gz
)

mkdir k8s
find eks-d-tmp -name kube-proxy -exec cp {} $KUBE_SNAP_BINS/$KUBE_ARCH/ \;
find eks-d-tmp -name kubelet -exec cp {} $KUBE_SNAP_BINS/$KUBE_ARCH/ \;
find eks-d-tmp -name kube-controller-manager -exec cp {} $KUBE_SNAP_BINS/$KUBE_ARCH/ \;
find eks-d-tmp -name kube-scheduler -exec cp {} $KUBE_SNAP_BINS/$KUBE_ARCH/ \;
find eks-d-tmp -name kubectl -exec cp {} $KUBE_SNAP_BINS/$KUBE_ARCH/ \;
