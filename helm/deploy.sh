#!/bin/bash
set -e

echo "deploying $1"

# Configure Helm
helm init --client-only
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
helm repo add weaveworks https://weaveworks.github.io/flux

# Kube 2 IAM secrets
account_id=$(../scripts/get_parameter.py -n $1.account_id -r)

helm upgrade --install kube2iam stable/kube2iam -f kube2iam.yaml --namespace kube-system \
    --set extraArgs.base-role-arn="arn:aws:iam::$account_id:role/"

# ALB Ingress Controller
helm upgrade --install alb-ingress incubator/aws-alb-ingress-controller \
    --namespace ingress-controller \
    -f alb-ingress.yaml

# MGMT tool secrets
tenant_id=$(../scripts/get_parameter.py -n $1.tenant_id -r)
client_id=$(../scripts/get_parameter.py -n $1.client_id -r)
client_secret=$(../scripts/get_parameter.py -n $1.client_secret -r)
domain=$(../scripts/get_parameter.py -n $1.domain -r)
grafana_password=$(../scripts/get_parameter.py -n $1.grafana_password -r)

domain="dev.dea.ga.gov.au"

helm upgrade --install mgmt \
    ./mgmt \
    -f ../infra/cluster_defaults.yaml \
    --set azure.tenantID="$tenant_id" \
    --set azure.clientID="$client_id" \
    --set azure.clientSecret="$client_secret" \
    --set azure.emailDomain="ga.gov.au" \
    --set domain="$domain" \
    --set legoEmail="administrator@gadevs.ga" \
    --set teamName="deacepticons"

helm upgrade --install prometheus-operator coreos/prometheus-operator --namespace monitoring
helm upgrade --install \
    kube-prometheus coreos/kube-prometheus \
    --namespace monitoring \
    -f grafana.yaml \
    --set grafana.adminPassword="$grafana_password" \
    --set alertmanager.service.type="NodePort"

# Create prometheus monitoring resources
kubectl apply -f monitoring

# Fluentd for logging to cloudwatch
helm upgrade --install fluentd-cloudwatch incubator/fluentd-cloudwatch -f fluentd-cloudwatch.yaml --namespace kube-system

# Autoscaler for nodes
# helm upgrade --install cluster-autoscaler stable/cluster-autoscaler -f autoscaler.yaml --namespace kube-system

# Metrics Server for Horizontal Pod Autoscaling
helm upgrade --install metrics-server stable/metrics-server -f metrics-server.yaml --namespace kube-system

# Sysdig falco for container security monitoring
# helm upgrade --install falco stable/falco -f falco.yaml -f falco-rules.yaml

# Install WeaveWorks flux

# Add WeaveWorks HelmRelease CRD
kubectl apply -f https://raw.githubusercontent.com/weaveworks/flux/master/deploy-helm/flux-helm-release-crd.yaml

# branch=$(echo ${1:-datakube-dev} | cut -d "-" -f 2)
branch="eks"
emoji=":ballmer-hype:"
posting_name="[EKS] Flux Deployer"


# Generate SSH keypair if private key does not already exist as a secret
# can get public key later using: fluxctl --k8s-fwd-ns=flux identity
if ! kubectl get secret -n flux flux-git-ssh
then
    if ! kubectl get ns flux
    then
        kubectl create ns flux
    fi
    ssh-keygen -q -N "" -f ./identity
    kubectl -n flux create secret generic flux-git-ssh --from-file=./identity
    rm ./identity
    cat ./identity.pub
    rm ./identity.pub
fi

# If you set the label to be the same as your branch you're going to have a real bad time

helm upgrade --install flux \
    -f flux.yaml \
    --set git.url=git@bitbucket.org:geoscienceaustralia/datakube-apps.git \
    --set git.branch="${branch}" \
    --set git.secretName=flux-git-ssh \
    --set git.label="datacube-${branch}" \
    --namespace flux \
    weaveworks/flux

# Install fluxcloud to perform notifications without WeaveCloud subscription
# yq subsitution is quite fragile, however yq currently (2.2.1) doesn't support advanced merging
# of arrays which would let us place the changed variables in a seperate file
yq w -d1 fluxcloud.yaml "spec.template.spec.containers[0].env[4].value" "$posting_name" |
    yq w -d1 - "spec.template.spec.containers[0].env[5].value" "$emoji" |
    kubectl apply -n flux -f -
