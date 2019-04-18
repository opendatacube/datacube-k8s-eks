#! /usr/bin/env bash

# creates a database called ${name} 

while getopts ":n:" o; do
    case "${o}" in
        n)
            name=${OPTARG}
            ;;
    esac
done

# Get or set credentials 
db_username=$(../scripts/get_parameter.py -n "${name}.db_username" -v "${name}")
db_password=$(../scripts/get_parameter.py -n "${name}.db_password")

helm repo add datacube-charts https://opendatacube.github.io/datacube-charts/charts/
helm repo update
helm install datacube-charts/datacube --name ${name} \
    -f ../infra/cluster_defaults.yaml \
    -f create-db.yaml \
    --set global.externalDatabase.database=${name} \
    --set global.externalDatabase.username=${db_username} \
    --set global.externalDatabase.password=${db_password} \
|| echo "Skipping deployment"
