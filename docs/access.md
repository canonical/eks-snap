# Access the EKS snapped Kubernetes

### Opening port 16443
To reach the cluster traffic has to be allowed to reach port _16443_ where the Kubrnetes server is listening at.
On an EC2 instance you need to follow the 
[AWS docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/authorizing-access-to-an-instance.html) in order to set
proper inbound rules in the security groups associated with the instance.
 
### Issuing certificates for the public IP
When kubectl sends a request to the cluster's API server it checks the certificate used by the API server to ensure
it is indeed talking to the right service. On EC2 instances a public IP and DNS entry is assigned when the VM starts.
The EKS snap will issue certificates valid for the IPs detected in the VM's interfaces. However the AWS public IP and
DNS entry is not present in the machines interfaces so if we want to access the cluster through the AWS provided public
IP/DNS, we will have to manually instruct the EKS snap what the public endpoints are. To do so we edit the
 `/var/snap/eks/current/certs/csr.conf.template` file and after the `#MOREIPS` line to insert:
```dtd
DNS.99 = <Public IPv4 address>
IP.99 = <Public IPv4 DNS>
```

## References

 * [Authorizing inbound traffic for your Linux instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/authorizing-access-to-an-instance.html)
