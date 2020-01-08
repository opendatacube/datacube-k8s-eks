# Live Examples to excercise this suite of TerraForm Modules

## Usage
- Change directory to *examples/stage/odc_eks/*
- Run *terraform init* to initialize Terraform state tracking
- Run *terraform plan* to do a dry run and validate examples and interaction of modules
- Select the correct AWS credentials to use with sufficient priviledges to spin up the infrastructure *export AWS_PROFILE=admin*
- Run *terraform apply* to spin up infrastructure (a new ODC EKS Cluster), can take upto 15-20minutes.
- Validate a fresh kubernetes cluster has been created by adding a new kubernetes context and getting clusterinfo
  - aws eks update-kubeconfig --name odc-test-stage-odc-eks
  - kubectl cluster-info
- Change directory to *examples/stage/odc_k8s/*
- Run terraform init, plan, apply as above and deploy flux, tiller etc. to the live k8s cluster.
- Get pods from the kubernetes admin namespace to verify services such as flux and tiller got deployed.
- Run *terraform destroy* to pull down the example EKS cluster pods/CD services.
- Get pods from kubernetes admin namespace to verify admin pods have been squashed.
- Change directory back to *examples/stage/odc_eks/*
- Run *terraform destroy* to pull down the example EKS, RDS and everything else can take upto 15minutes.
