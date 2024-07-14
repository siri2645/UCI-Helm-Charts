#!/bin/bash

namespace="jfrog"

# Generate MASTER_KEY and JOIN_KEY
export MASTER_KEY=$(openssl rand -hex 32) 
echo "MASTER_KEY: ${MASTER_KEY}"

export JOIN_KEY=$(openssl rand -hex 32)
echo "JOIN_KEY: ${JOIN_KEY}"

# Install/Upgrade Artifactory with Helm
helm upgrade --install jfrog --set artifactory.replicaCount=1 --set artifactory.masterKey=${MASTER_KEY} --set artifactory.joinKey=${JOIN_KEY} --namespace $namespace --create-namespace jfrog/artifactory --values jfrog-values.yaml