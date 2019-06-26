# Datacube Kubernetes EKS

:warning: This is still a work in progress and doesn't have an official release :warning:

This repository will build and manage a production scale kubernetes cluster using the AWS EKS engine
for running Open Data Cube applications. 

[![Master](https://circleci.com/gh/opendatacube/datacube-k8s-eks/tree/master.svg?style=shield)](https://circleci.com/gh/opendatacube/datacube-k8s-eks/tree/master)

---

# Supported Features

* EKS cluster with PostgreSQL database
* Multi-factor Authentication enforcement for Admin users
* Scale applications based on usage
* Scale cluster to fit application requirements
* Spot instance support
* Send logs to cloudfront
* Application load balancers with automatically generated certificates
* Optional Cloudfront distribution with automatically generated certificates
* Automatically register route53 DNS records
* Inspect cluster metrics using Prometheus and Grafana

# Getting started

Follow our [Getting Started Guide](docs/getting_started.md) to deploy your first cluster and learn how to customise your build.

# Documenation

* [Additional Users](docs/additional_users.md) - How to add users and configure access
* [Patching](docs/patching_upgrading.md) - How to keep the kubernetes nodes up to date
* [Addons](docs/addons.md) - Notes on how to install and configure various addons
* [Troubleshootin](docs/troubleshooting.md) - Workarounds to fix common issues

