#!/bin/bash

namespace="jfrog"

# Add JFrog Helm repo and update
helm repo add jfrog https://charts.jfrog.io
helm repo update

# Generate MASTER_KEY and JOIN_KEY
export MASTER_KEY=$(openssl rand -hex 32) 
echo "MASTER_KEY: ${MASTER_KEY}"

export JOIN_KEY=$(openssl rand -hex 32)
echo "JOIN_KEY: ${JOIN_KEY}"

# Install/Upgrade Artifactory with Helm
helm upgrade --install artifactory --set artifactory.replicaCount=3 --set artifactory.masterKey=${MASTER_KEY} --set artifactory.joinKey=${JOIN_KEY} --namespace $namespace --create-namespace jfrog/artifactory --values jfrog-values.yaml


# Get the PostgreSQL password from the secret and decode it
POSTGRESQL_PASSWORD=$(kubectl get secret jfrog-secrets -n $namespace -o jsonpath='{.data.postgresql_password}')


# Export the PostgreSQL password
export POSTGRESQL_PASSWORD


kubectl patch secret artifactory-postgresql -n $namespace --type='json' -p='[{"op": "replace", "path": "/data/postgresql-password", "value":"'"$POSTGRESQL_PASSWORD"'"}]'


echo "artifactory-postgres secret updated successfully"

# Define patterns for pod names to delete
PATTERNS=("artifactory-0" "artifactory-1" "artifactory-2")

# Get all pods in the specified namespace
ALL_PODS=$(kubectl get pods -n $namespace -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')

# Iterate over each pattern and delete matching pods
for PATTERN in "${PATTERNS[@]}"; do
  for POD in $ALL_PODS; do
    if [[ $POD == *$PATTERN* ]]; then
      echo "Deleting pod: $POD"
      kubectl delete pod $POD -n $namespace
    fi
  done
done

echo "All specified pods in the $namespace namespace have been deleted."
