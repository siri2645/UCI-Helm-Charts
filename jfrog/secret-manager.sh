#!/bin/bash

echo "Before executing this script need to create IAM Identity Provider for our cluster and make it has thump printed"
echo " "
echo "Now executing another script to create role and so on..."
sh role-policy-sa.sh
sh jfrog-secrets-update.sh

# Variables
NAMESPACE="external-secrets"
RELEASE_NAME="external-secrets"

HELM_REPO_EXIST=$(helm repo list | grep external-secrets)
  if [ -z "$HELM_REPO_EXIST" ]; then
    echo "Adding Helm repository for external-secrets..."
    helm repo add external-secrets https://charts.external-secrets.io
    if [ $? -ne 0 ]; then
      echo "Failed to add Helm repository."
      exit 1
    fi
  else
    echo "Helm repository for external-secrets is already added."
  fi

    # Update the Helm repository
  helm repo update
  if [ $? -ne 0 ]; then
    echo "Failed to update Helm repository."
    exit 1
  fi

  # Install external-secrets with some required CRDS
  echo "Install external-secrets with some required CRDs" 

# Check if the namespace exists
echo "Checking if the namespace $NAMESPACE exists..."
kubectl get namespace $NAMESPACE > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Namespace $NAMESPACE already exists. Skipping installation."
  echo "Deploying external-secret.yaml and secret-store.yaml"
  kubectl create -f jfrogdb-externalsecrets.yaml
  kubectl create -f jfrogdb-secretstore.yaml
  exit 0
else
  echo "Namespace $NAMESPACE does not exist. Proceeding with installation..."
fi

# Install external-secrets using Helm
helm install $RELEASE_NAME external-secrets/external-secrets --namespace $NAMESPACE --create-namespace --set installCRDs=true

if [ $? -eq 0 ]; then
  echo "external-secrets successfully installed."
  echo "Deploying external-secrets.yaml and secret-store.yaml"
  kubectl create -f jfrogdb-externalsecrets.yaml
  kubectl create -f jfrogdb-secretstore.yaml
else
  echo "Failed to install external-secrets and manifest files."
  exit 1
fi


