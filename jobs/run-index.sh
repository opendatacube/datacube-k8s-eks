#! /usr/bin/env bash

while getopts ":n:t:" o; do
    case "${o}" in
        n)
            name=${OPTARG}
            ;;
        t)
            template=${OPTARG}
            ;;
    esac
done

helm repo add datacube-charts https://opendatacube.github.io/datacube-charts/charts/
helm repo update
helm fetch --untar datacube-charts/datacube-index
helm template datacube-index -x templates/index.yaml -f $template  | kubectl create -f -
rm -r datacube-index