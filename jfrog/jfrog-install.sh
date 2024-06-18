#!/bin/bash

namespace="jfrog"

helm repo add jfrog https://charts.jfrog.io
helm repo update

export MASTER_KEY=$(openssl rand -hex 32) 
echo ${MASTER_KEY}

export JOIN_KEY=$(openssl rand -hex 32)
echo ${JOIN_KEY}

helm upgrade --install artifactory --set artifactory.replicaCount=3 --set artifactory.masterKey=${MASTER_KEY} --set artifactory.joinKey=${JOIN_KEY} --namespace $namespace --create-namespace jfrog/artifactory --values jfrog-values.yaml

POSTGRESQL_PASSWORD=$(kubectl get secret jfrog-secret -n $namespace -o jsonpath='{.data.postgresql_password}')

export POSTGRESQL_PASSWORD

kubectl patch secret artifactory-postgresql -n $namespace --type='json' -p='[{"op": "replace", "path": "/data/postgresql-password", "value":"'"$POSTGRESQL_PASSWORD"'"}]'

echo "artifactory-postgres secret updated successfully"

PATTERNS=("artifactory-0" "artifactory-1" "artifactory-2")

ALL_PODS=$(kubectl get pods -n $namespace -o jsonpath='{.items[*].metadata.name}')

# Iterate over each pattern and delete matching pods
for PATTERN in "${PATTERNS[@]}"; do
  for POD in $ALL_PODS; do
    if [[ $POD == *$PATTERN* ]]; then
      echo "Deleting pod: $POD"
      kubectl delete pod $POD -n $namespace
    fi
  done
done

echo "All specified pods in the $namespace have been deleted."
