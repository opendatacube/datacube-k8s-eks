#
# Values for EFS provisioner service
# https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs
#
## Deploy environment label, e.g. dev, test, prod
##
global:
  deployEnv: dev
## Containers
##
replicaCount: 1
revisionHistoryLimit: 10
image:
  repository: quay.io/external_storage/efs-provisioner
  tag: v2.2.0-k8s1.12
  pullPolicy: IfNotPresent
busyboxImage:
  repository: gcr.io/google_containers/busybox
  tag: 1.27
  pullPolicy: IfNotPresent
## Deployment annotations
##
annotations: {}
## Configure provisioner
## https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs#deployment
##
efsProvisioner:
  # If specified, use this DNS or IP to connect the EFS
  dnsName: ${dnsName}
  efsFileSystemId: ${efsFileSystemId}
  awsRegion: ${awsRegion}
  path: ${path}
  provisionerName: example.com/aws-efs
  storageClass:
    name: efs
    isDefault: false
    gidAllocate:
      enabled: true
      gidMin: 40000
      gidMax: 50000
    reclaimPolicy: Delete
    mountOptions: []
      # - acregmin=3
      # - acregmax=60
## Enable RBAC
## Leave serviceAccountName blank for the default name
##
rbac:
  create: true
  serviceAccountName: ""
## Annotations to be added to deployment
##
podAnnotations: {
  iam.amazonaws.com/role: ${iam_role_name}
}
## Node labels for pod assignment
##
nodeSelector: {}
# Affinity for pod assignment
# Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
affinity: {}
# Tolerations for node tains
tolerations: {}
## Configure resources
##
resources: {}
  # To specify resources, uncomment the following lines, adjust them as necessary,
  # and remove the curly braces after 'resources:'.
  # limits:
  #  cpu: 200m
  #  memory: 128Mi
  # requests:
  #  cpu: 100m
  #  memory: 128Mi