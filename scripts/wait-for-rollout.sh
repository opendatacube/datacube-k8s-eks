#! /usr/bin/env bash

# Pass path
cd "$1"
for f in *.yaml; do
    # Get the file without suffix
    kubectl get deployments --output=custom-columns=NAME:.metadata.name \
        | grep "${f%.*}" \
        | xargs -n1 kubectl rollout status --watch --timeout 30m deployment
done
