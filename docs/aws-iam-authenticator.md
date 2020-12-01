# User authentication with AWS IAM

On EC2 instances the aws-iam-authenticator is already deployed in the `kube-system` namespace. To complete the
installation you need to first map AWS to kubernetes users and second setup your kubectl to use the IAM service.

### Mapping users

The ConfigMap used to associate users and permissions can be edited with: 
```dtd
eks kubectl edit -n kube-system   cm/aws-iam-authenticator
```
See '[Managing users or IAM roles for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)'
for details on how to reach a mapping that will match your needs.


### Configuring kubectl

On your workstation kubectl needs to use your AWS credentials to contact your EKS cluster.
 
 * You should have a working set of AWS credentials. It is recommended to install the [AWS cli](https://aws.amazon.com/cli/)
  that will guide you in 
  [configuring and verifing](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) your setup. 
 * Install the aws-iam-authenticator. The AWS authenticator is called by kubectl and produces a token. This token is
  used to map you to a Kubernetes user. The installation steps depend on the workstation you are on. Please follow the
  steps described in the [official docs](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html).
 * To [produce a kubeconfig](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html) file start from the template:
 ```dtd
apiVersion: v1
clusters:
- cluster:
    server: <endpoint-url>
    certificate-authority-data: <base64-encoded-ca-cert>
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: <aws-iam-authenticator>
      args:
        - "token"
        - "-i"
        - "<cluster-name>"
        # - "-r"
        # - "<role-arn>"
      # env:
        # - name: AWS_PROFILE
        #   value: "<aws-profile>"
```
   1. Replace `<endpoint-url>` with the endpoint of your cluster. If you intend to access the cluster from outside EC2
    through the node's public endpoints (IP/DNS) please see the [respective document](access.md). Note that the EKS snap
    configures the API server to listen on all interfaces.
   1. Replace `<base64-encoded-ca-cert>` with the base64 representation of the clusters CA. Copy this from the output of
    `eks config`.
   1. Replace `<aws-iam-authenticator>` with the full path of where the `aws-iam-authenticator` binary is installed.
   1. Replace `<cluster-name>` with the cluster ID shown with `eks.kubectl describe -n kube-system   cm/aws-iam-authenticator | grep clusterID`
 * Install kubectl, eg on Linux `sudo snap install kubectl` and have it use the just created kubeconfig file with the
  `--kubeconfig` parameter.

## References
 * [Configuration Format](https://github.com/kubernetes-sigs/aws-iam-authenticator#full-configuration-format)
 * [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
 * [How to use aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator)
 * [AWS cli](https://aws.amazon.com/cli/)
 * [Configuring AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
 * [Install AWS authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
 * [Create a EKS kubeconfig file](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
 * [Produce a kubeconfig](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)