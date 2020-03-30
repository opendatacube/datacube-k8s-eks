# Live Examples to exercise this suite of TerraForm Modules

## Usage
- Select the correct AWS credentials to use with sufficient priviledges to spin up the infrastructure, e.g. `export AWS_PROFILE=admin`
- Create a backend to store terraform state if requires. There is an example provided under `examples/backend_int` that creates s3 bucket to store terraform state and dynamodb table to store terraform state lock. 
- To create a full Open Data Cube (ODC) eks infrastructure on AWS platform, execute each modules defined under `examples/stage/<module>`. Please note that number in front, e.g. `01_`, represents it's order of execution to manage dependencies.
- You require to adjust some of the configuration params such as `owner`, `namespace`, `environment`, `region` and `terraform backend` - unique to your organisation.

## How to setup a new ODC cluster environment
Once you have create a terraform backend and updated a configuration parameters, you can perform following steps to setup a new ODC cluster environment -
- Change directory to `examples/stage/01_odc_eks/`
- Run `terraform init` to initialize Terraform state tracking
- Run `terraform plan` to do a dry run and validate examples and interaction of modules
- Run `terraform apply` to spin up infrastructure (a new ODC EKS Cluster), can take upto 15-20minutes
- Validate a fresh kubernetes cluster has been created by adding a new kubernetes context and getting clusterinfo
```shell script
    aws eks update-kubeconfig --name <cluster-id>
    kubectl cluster-info
```
- Change directory to `examples/stage/02_odc_k8s/`
- Run `terraform init`, `terraform plan`, `terraform apply` as above and deploy flux, tiller etc. to the live k8s cluster
- Get pods from the kubernetes admin namespace to verify services such as flux and tiller got deployed
```shell script
  kubectl get pods —all-namespaces
```
- Optionally, you can execute `examples/stage/03_odc_apps_k8s` and `examples/stage/04_odc_k8s_sandbox`. This will setup a full sandbox/jupyterhub environment as well installs necessary components, roles and kubernetes secrets, etc to manage your cluster.
- Deploy apps using Flux and Helm Release. As part of this example, FluxCD is configured (in `o2_odc_k8s` module) to monitor [flux-odc-sample](https://github.com/opendatacube/flux-odc-sample) repo that defines Helm Releases for ODC cluster. Create your own live repo and update flux configuration.
- Fetch a flux deployment key and copy it to repo ssh public key or deploy keys section:
```bash
    kubectl -n flux logs deployment/flux | grep identity.pub |cut -d '"' -f2
```
- Make sure all the releases are deployed. Verify using - 
```shell script
  kubectl get hr —all-namespaces
```
- To access Grafana (prometheus), get the password using below command. It is base64 encoded password.
```shell script
  kubectl get secret prometheus-operator-grafana -n monitoring -o yaml | grep "admin-password:" | sed 's/admin-password: //' | base64 -d -i`
```

## Destroy a newly created infrastructure

1. Remove `flux` deploy ssh key. This will stop flux to read/write from your live repo.
2. Delete helm releases (HRs) in the following order. Assuming that you have similar setup as defined in example -
- First delete all the apps under `sandbox`, `processing` and `web` kubernetes namespace
```shell script
  kubectl delete hr --all=true -n sandbox
  kubectl delete hr --all=true -n processing
  kubectl delete hr --all=true -n web
```
- Delete prometheus-operator HR and CRDs and everything under monitoring namespaces
```shell script
  kubectl delete hr prometheus-operator -n monitoring
  kubectl delete crd prometheuses.monitoring.coreos.com
  kubectl delete crd prometheusrules.monitoring.coreos.com
  kubectl delete crd servicemonitors.monitoring.coreos.com
  kubectl delete crd podmonitors.monitoring.coreos.com
  kubectl delete crd alertmanagers.monitoring.coreos.com
  kubectl delete hr --all=true -n monitoring
```
- Delete all the apps under `admin` namespace. Also make sure external DNS has cleared all the DNS entry in Route53
```shell script
  kubectl delete hr --all=true -n admin
```
- Delete kube2iam
```shell script
  kubectl delete hr kube2iam -n kube-system
```

3. Destroy all the terraform infrastructure in reverse order. Run `terraform init --upgrade` and `terraform destroy` command under each namespace
- Destroy jupyterhub tf infra - `04_odc-k8s-sandbox`
- Destroy apps tf infra - `03_odc-k8s-apps`
- Destroy k8s tf infra - `02_odc-k8s`
- Destroy eks tf infra - `01_odc-eks`

## Troubleshoot - Known Issues 
* Issue deleting `01_odc_eks` module:
```text
    * VPC module destroy may have issue cleanup itself properly - 
    
     Error: Error deleting VPC: DependencyViolation: The vpc 'vpc-09a9c52f9a2a53a4e' has dependencies and cannot be deleted.
        status code: 400, request id: 4548f188-8f1e-4cb5-a8e8-c92ba56e9401
        
     Resolve: Destroy VPC manually
```