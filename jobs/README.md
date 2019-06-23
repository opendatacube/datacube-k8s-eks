# Datacube EKS Datacube Management Tasks

## Creating a Database & Initializing a Database
Creating a new psql database and user and initializing the database with datacube can be done by installing a helm chart.

### Requirements
* A psql database server
* A kubernetes secret with a `postgres-username` and `postgres-password` that provide admin access to the databasr server
* A Helm client
* Tiller initialized on the kubernetes cluster

### Installing the chart
Create a YAML configuration file which specifies the following:
* `database.create: true`
* `database.adminSecret: <psql admin secret>`
* `database.host: <db hostname>`
* `database.port: <db port>`
* `database.database: <name of database to create>`
Optionally you can specify a username and password for the user which will be created with:
* `database.username: <username>`
* `database.password: <password>`
If not specified, the username will be set to `database.database` and the password will be automatically generated. In either case the username and password will be stored in a kubernetes secret.

An example YAML configuration file can be viewed at `create-db.yaml`.

Once the YAML file is created install the helm chart.
```bash
helm upgrade --install <datacube name> "https://opendatacube.github.io/datacube-charts/charts/datacube-0.17.4.tgz" -f create-db.yaml
```

Once complete the database should be created and initialized for use with ODC. A secret should also have been created with the credentials to use the database named `<datacube name>-datacube`. The helm chart can now be deleted with
```bash
helm delete --purge <datacube name>
```

## Indexing Data
Indexing data into your datacube can be achieved using helm charts. For more information and examples please see the [datacube-index](https://github.com/opendatacube/datacube-charts/tree/master/stable/datacube-index) helm chart readme.

### Requirements
* psql database with datacube initialized

### Adding datacube products

### From Amazon S3
Create a YAML configuration file following the below example:
```YAML
database:
  database: datacube
  host: database.hostname.com
  existingSecret: datacube-secret
index:
  additionalEnvironmentVars:
    AWS_DEFAULT_REGION: ap-southeast-2
  annotations:
    iam.amazonaws.com/role: kube2iam_iam_role
  dockerArgs:
  - "/bin/bash"
  - "-c"
  - ""
  resources:
    requests:
      cpu: 300m
      memory: 768Mi
    limits:
      cpu: 500m
      memory: 2Gi
image:
  registry: docker.io
  tag: latest
  repository: opendatacube/datacube-index
  pullPolicy: IfNotPresent
datacube:
  configPath: /opt/odc/datacube.conf
```
The critical parts to check are:
* `database.existingSecret: <database credentials secret>`
* `database.host: <db hostname>`
* `database.database: <name of database to create>`
* `index.annotations.iam.amazonaws.com/role <kube2iam role name>`

Save this YAML file and make note of the name (example will call it `index_config.yaml`)

Finally run the following script to install a helm chart which will create an indexing job named 'wofls':
```console
helm upgrade --install wofls "https://opendatacube.github.io/datacube-charts/charts/datacube-index-0.4.0.tgz" -f index_config.yaml --set index.dockerArgs[2]="s3-find s3://dea-public-data/WOfS/WOFLs/v2.1.5/combined/**/*.yaml | s3-to-tar | dc-index-from-tar"
```
Once the job is complete, clean up the helm chart with
```console
helm delete --purge wofls
```
