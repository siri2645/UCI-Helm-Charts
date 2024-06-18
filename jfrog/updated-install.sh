#!/bin/bash

namespace="jfrog-helm"

helm repo add jfrog https://charts.jfrog.io
helm repo update

export MASTER_KEY=$(openssl rand -hex 32)
echo ${MASTER_KEY}

export JOIN_KEY=$(openssl rand -hex 32)
echo ${JOIN_KEY}

helm upgrade --install artifactory --set artifactory.replicaCount=1 --set artifactory.masterKey=${MASTER_KEY} --set artifactory.joinKey=${JOIN_KEY} --namespace $namespace --create-namespace jfrog/artifactory --values jfrog-helm-values.yaml

set -x  # Enable debugging

POSTGRESQL_PASSWORD=$(kubectl get secret jfrogdb-secrets -n $namespace -o jsonpath='{.data.postgresql_password}' | base64 --decode)
echo "Retrieved PostgreSQL Password: $POSTGRESQL_PASSWORD"

export POSTGRESQL_PASSWORD

# Verify if POSTGRESQL_PASSWORD variable is correctly set
if [ -z "$POSTGRESQL_PASSWORD" ]; then
  echo "Error: Failed to retrieve PostgreSQL password"
  exit 1
fi

# Update artifactory-postgresql secret with the decoded password
kubectl patch secret artifactory-postgresql -n jfrog-helm \
  --type='json' \
  -p='[{"op": "replace", "path": "/data/postgresql-password", "value":"'"$POSTGRESQL_PASSWORD"'"}]'

echo "artifactory-postgresql secret updated successfully"

set -x  # Enable debugging

# Array declaration with patterns
PATTERNS=("artifactory-0")

# Get all pods in the namespace
ALL_PODS=$(kubectl get pods -n $namespace -o jsonpath='{.items[*].metadata.name}')

# Check if ALL_PODS is empty
if [ -z "$ALL_PODS" ]; then
  echo "No pods found in namespace $namespace"
  exit 1
fi

# Iterate over each pattern and delete matching pods
for PATTERN in "${PATTERNS[@]}"; do
  echo "Processing pattern: $PATTERN"

  # Iterate over all pods and delete those matching the current pattern
  for POD in $ALL_PODS; do
    if [[ $POD == *$PATTERN* ]]; then
      echo "Deleting pod: $POD"
      kubectl delete pod "$POD" -n "$namespace"
      if [ $? -ne 0 ]; then
        echo "Error deleting pod: $POD"
        exit 1
      fi
    fi
  done
done

echo "All specified pods in the $namespace have been deleted."
