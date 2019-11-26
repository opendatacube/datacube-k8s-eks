# Kubewatch
[kubewatch](https://github.com/bitnami/charts/tree/master/upstreamed/kubewatch) is a Kubernetes watcher that currently publishes kubernetes resources notification in the EKS Cluster to Slack channel.


## Kubewatch configurable parameters of the kubewatch chart
Assign values to the kubewatch configurable parameters, to watch kubernetes resources:

```text
To monitor k8s deployments and push notification to a webhook url, set the following vars:

kubewatch_enabled=true
kubewatch_webhook_enabled=true
kubewatch_webhook_url="https://hooks.slack.com/services/<sample>/<test>/<token>"
kubewatch_resourcesToWatch_deployment=true
```
