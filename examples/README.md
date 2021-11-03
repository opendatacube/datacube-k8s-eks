# Live Examples to exercise this suite of TerraForm Modules

## Usage
- Select the correct AWS credentials to use with sufficient privileges to spin up the infrastructure, e.g. `export AWS_PROFILE=admin`
- Create a backend to store terraform state if requires. There is an example provided under `examples/backend_int` that creates the s3 bucket to store terraform state and the dynamodb table to store terraform state lock.
- To create a full Open Data Cube (ODC) eks infrastructure on AWS platform, execute each module defined under `examples/stage/<module>`. Please note that the number in front, e.g. `01_`, represents the correct order of execution to manage dependencies.
- You need to adjust some of the configuration params such as `owner`, `namespace`, `environment`, `region` and `terraform backend` - so they are unique to your organisation.

## How to setup a new ODC cluster environment
Once you have created a terraform backend and updated the configuration parameters, you can perform the following steps to setup a new ODC cluster environment -
- Change directory to `examples/stage/01_odc_eks/`
- Modify `data_providers.tf`:
  - Change `region`, `owner`, `namespace`, and `environment` to the values from `backend_init`.
  - If you do not want a database change `db_enabled` to `false`
- Modify `main.tf`:
  - `bucket`: `<namespace>-<environment>-backend-tfstate`
  - `region` : `<region>`
- Run `terraform init` to initialize Terraform state tracking
- Run `terraform plan` to do a dry run and validate examples and interaction of modules
- Run `terraform apply` to spin up infrastructure (a new ODC EKS Cluster), -- can take upto 15-20 minutes
- Validate a fresh kubernetes cluster has been created by adding a new kubernetes context and getting clusterinfo
```sh
aws eks update-kubeconfig --name <cluster-id>
kubectl cluster-info
```
- Change directory to `examples/stage/02_odc_k8s/`
- Modify `data_providers.tf` with the following:
  - Modify the `bucket` and `region` such that:
    - `bucket`: `<namespace>-<environment>-backend-tfstate`
    - `region` : `<region>`
- Modify `main.tf`:
  - `bucket`: `<namespace>-<environment>-backend-tfstate`
  - `region` : `<region>`
- Run `terraform init`, `terraform plan`, `terraform apply` as above and deploy flux, helm etc. to the live k8s cluster
- If you enabled the database it is now when you need to create the AWS SSM variables for the database access. The name of the new variable should be `/<namespce>-<environment>-eks/ows_ro/db.creds` And should have the content of `<db_username>:<db_password>`
- Get pods from the kubernetes admin namespace to verify services such as flux and helm were deployed
```sh
kubectl get pods —all-namespaces
```

## Deploy apps using Flux and Helm Release
- FluxCD is configured (in `02_odc_k8s` module) to monitor [flux-odc-sample](https://github.com/opendatacube/flux-odc-sample) repo that defines Helm Releases for the ODC cluster. Create your own live repo and update flux configuration.
- Execute example modules `examples/stage/03_odc_apps_k8s` and `examples/stage/04_odc_k8s_sandbox`.
- For each of the stages `03` and `04` you need to modify the following files:
  - Modify `data_providers.tf` with the following:
    - Modify the `bucket` and `region` such that:
      - `bucket`: `<namespace>-<environment>-backend-tfstate`
      - `region` : `<region>`
  - Modify `main.tf`:
    - `bucket`: `<namespace>-<environment>-backend-tfstate`
    - `region` : `<region>`
This will setup a full sandbox/jupyterhub environment, ows web service and also installs necessary admin & monitoring components, roles and kubernetes secrets, etc to manage your cluster.
- Fetch a flux deployment key and copy it to repo ssh public key or deploy keys section:
```sh
kubectl -n flux logs deployment/flux | grep identity.pub |cut -d '"' -f2
```
- Make sure all the releases are deployed. Verify using -
```sh
kubectl get hr —all-namespaces
```
- To access Grafana (prometheus), get the password using the below command. It is a base64 encoded password.
```sh
kubectl get secret prometheus-operator-grafana -n monitoring -o yaml | grep "admin-password:" | sed 's/admin-password: //' | base64 -d -i`
```

## Destroy a newly created infrastructure

1. Remove `flux` deploy ssh key. This will stop flux from being able to read/write from your live repo.
2. Delete helm releases (HRs) in the following order. Assuming that you have a similar setup as defined in example -
- First delete all the apps under `sandbox`, `processing` and `web` kubernetes namespace
```sh
kubectl delete hr --all=true -n sandbox
kubectl delete hr --all=true -n processing
kubectl delete hr --all=true -n web
```
- Delete prometheus-operator HR and CRDs and everything under monitoring namespaces
```sh
kubectl delete hr prometheus-operator -n monitoring
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com
kubectl delete hr --all=true -n monitoring
```
- Delete all the apps under `admin` namespace. Also make sure external DNS has cleared all the DNS entry in Route53
```sh
kubectl delete hr --all=true -n admin
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
