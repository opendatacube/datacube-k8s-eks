#! /usr/bin/env bash

kubectl create secret generic cluster-defaults \
    --from-file=../infra/cluster_defaults.yaml \
    --dry-run -o yaml | \
    kubectl apply -f -