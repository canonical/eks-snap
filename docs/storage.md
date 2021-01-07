# EBS and EFS storage on AWS

Both [EBS](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
and [EFS](https://github.com/kubernetes-sigs/aws-efs-csi-driver) storage drivers are enabled during the
`eks init` command. Make sure you 
[understand their differences](https://containerjournal.com/topics/container-networking/using-ebs-and-efs-as-persistent-volume-in-kubernetes/)
before selecting one. Depending on the the storage solution selected certain configuration arguments need to be provided
during the init process. 


## Amazon Elastic Block Store - EBS
The driver requires IAM permission to manage Amazon EBS volumes on user's behalf. An IAM user with proper permissions
needs to be provided during `eks init`. You will be asked for the user's key ID and access ID.

To test the setup after calling `eks init` you can create a PVC:
```dtd
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 4Gi
``` 
And use it in a pod:
```dtd
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: centos
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo $(date -u) >> /data/out.txt; sleep 5; done"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: ebs-claim
```

To verify everything:
```dtd
sudo eks.kubectl exec -ti app -- tail -f /data/out.txt
``` 


## Amazon Elastic File System - EFS
EFS file system needs to be created following the 
[respective instructions](https://docs.aws.amazon.com/efs/latest/ug/gs-step-two-create-efs-resources.html) so it can be
be mounted inside containers. To setup EFS with the EKS snap you will need the File system ID of EFS. Make sure the file
system you create is accessible in the EC2 VM where the snap is running.

To test the setup after calling `eks init` you can create a PVC:
```dtd
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
``` 
And use it in a pod:
```dtd
apiVersion: v1
kind: Pod
metadata:
  name: app1
spec:
  containers:
  - name: app1
    image: busybox
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo $(date -u) >> /data/out1.txt; sleep 5; done"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: efs-claim
```

To verify everything:
```dtd
sudo eks.kubectl exec -ti app1 -- tail -f /data/out1.txt
``` 


# References
 - https://containerjournal.com/topics/container-networking/using-ebs-and-efs-as-persistent-volume-in-kubernetes/
 - https://github.com/kubernetes-sigs/aws-ebs-csi-driver
 - https://github.com/kubernetes-sigs/aws-efs-csi-driver
 - https://docs.aws.amazon.com/efs/latest/ug/gs-step-two-create-efs-resources.html 