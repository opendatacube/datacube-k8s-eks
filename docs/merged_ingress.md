# Merged Ingress
Currently the ALB Ingress Controller will create a new AWS ALB resource for each ingress resource declared in the EKS Cluster. While the grouping ingresses together is a [feature in progress](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/issues/914), it is not yet ready for release.

## Ingress Merge Controller
It is possible to arbitrarily combine ingresses using the [Ingress Merge Controller](https://github.com/jakubkulhan/ingress-merge). This allows related k8s ingress resources to be combined into a single ALB. In order to install it into the cluster:
```console
git clone https://github.com/jakubkulhan/ingress-merge.git
cd ingress-merge
helm install --namespace ingress-controller --name ingress-merge ./helm
```
Use a config map to define a merged ingress, this config map will name the final ingress resource and is where you provide the ALB ingress controller annotations:
```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: merged-ingress
data:
  annotations: |
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/healthcheck-path: "/"
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: <arn>
    alb.ingress.kubernetes.io/connection-idle-timeout: 60
```

To have ingresses merged into this resource specify the following annotations:
```YAML
kubernetes.io/ingress.class: merge
merge.ingress.kubernetes.io/config: merged-ingress
```
Note that `merge.ingress.kubernetes.io/config: merged-ingress` matches the name (`merged-ingress`) of the config map.