# Kubewatch
[kubewatch](https://github.com/bitnami/charts/tree/master/upstreamed/kubewatch) is a Kubernetes watcher that currently publishes kubernetes resources notification in the EKS Cluster to Slack channel.


## Kubewatch configuration file
Use a kubewatch config map to define the configurable parameters for the kubewatch chart to watch kubernetes resources:

```YAML
### kubewatch-configmap.yaml
### ------------------------
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubewatch
data:
  .kubewatch.yaml: |
    handler:
      slack:
        enabled: false  ## Disable (since we are using webhook url instead of specifying slack api token)
      webhook:
        enabled: true
        url: "https://hooks.slack.com/services/<sample>/<test>/<token>"
    resource:
      deployment: true
      replicationcontroller: false
      replicaset: false
      daemonset: false
      services: true
      pod: false
      job: true
      persistentvolume: true
      namespace: false
      secret: true
      configmap: true
      ingress: true
```

# Execute command:

``` bash
kubectl apply -f kubewatch-configmap.yaml
```
