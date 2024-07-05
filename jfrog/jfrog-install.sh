#!/bin/bash

namespace="jfrog"

# Add JFrog Helm repo and update
helm repo add jfrog https://charts.jfrog.io
helm repo update

# Install/Upgrade Artifactory with Helm
helm upgrade --install artifactory --set artifactory.replicaCount=1 --namespace $namespace --create-namespace jfrog/artifactory --values jfrog-postgres-values.yaml
