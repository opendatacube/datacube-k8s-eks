#!/bin/bash
# Function : Initialize OWS DB Reader

# Pre-requisites: Logged into pod with database access with superuser password at hand
# If the superuser password is in k8s secrets the following sequence will get you access
# kubectl aliases are installed otherwise use full commands. It is assumed that a datacube is
# initialized with ownership on `agdc` schema.
#############################################################################################################################
# kubectl cp init_sandbox_db.sh <pod_name>:/code -n <pod_namespace>
# export DB_PASSWD=$(kgsec db -o yaml | grep "postgres-password:" | sed 's/postgres-password: //' | base64 -d -i)
# kubectl exec -it <pod_name> -n <pod_namespace> -- env DB_PASSWORD=$DB_PASSWD /bin/bash /code/init_sandbox_db.sh
#############################################################################################################################

# Random password generator from https://gist.github.com/earthgecko/3089509
random-string()
{
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

if [[ -z ${DB_HOSTNAME} || -z ${ADMIN_PASSWORD} || -z ${CLUSTER_ID} ]]; then
  echo "Please provide following env variables: DB_HOSTNAME, ADMIN_PASSWORD, CLUSTER_ID"
  exit 1;
fi

# DB_PASSWORD here is DB superuser password extracted from k8s secrets
export PGPASSWORD=${ADMIN_PASSWORD}
ADMIN_USER=superuser
DB_PORT=${DB_PORT:-"5432"}
DB_NAME=${DB_DATABASE:-"ows"}
REGION=${REGION:-"ap-southeast-2"}

NEW_DB_USER=owsreader
DC_SCHEMA=agdc

echo "Creating OWS Reader login role"
createuser -h "$DB_HOSTNAME" -p "$DB_PORT" -U "$ADMIN_USER" "$NEW_DB_USER" || true

echo "Resetting OWS Reader user password"
random=$(random-string 16)
psql -h "$DB_HOSTNAME" -p "$DB_PORT" --username "$ADMIN_USER" -d postgres -c "ALTER USER $NEW_DB_USER WITH PASSWORD '$random'"

echo "Giving read access to agdc schema to OWS Reader"
psql -h "$DB_HOSTNAME" -p "$DB_PORT" -U "$ADMIN_USER" -d "$DB_NAME" -c "GRANT USAGE ON SCHEMA $DC_SCHEMA TO $NEW_DB_USER;"
psql -h "$DB_HOSTNAME" -p "$DB_PORT" -U "$ADMIN_USER" -d "$DB_NAME" -c "GRANT SELECT ON ALL TABLES IN SCHEMA $DC_SCHEMA TO $NEW_DB_USER;"


echo "Adding OWS Reader user credentials to param-store"
aws ssm put-parameter --region "${REGION}" \
  --name "/${CLUSTER_ID}/ows_reader/db.creds" \
  --value "${NEW_DB_USER}:${random}" \
  --description "OWS Reader user credentials" \
  --type "SecureString" --overwrite