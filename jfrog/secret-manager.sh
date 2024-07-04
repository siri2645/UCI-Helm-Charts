#!/bin/bash

# Define all the variables for the scripts here
# You can also define the path to the scripts if they are in different directories

# Variables
NAMESPACE="external-secrets"     #external-secrets namespace
RELEASE_NAME="external-secrets"
HELM_REPO_URL="https://charts.external-secrets.io"

sh role-policy-sa.sh
sh jfrog-secrets-update.sh


# Check if the Helm repository for external-secrets exists
HELM_REPO_EXIST=$(helm repo list | grep external-secrets)

if [ -z "$HELM_REPO_EXIST" ]; then
    echo "Adding Helm repository for external-secrets..."
    helm repo add external-secrets $HELM_REPO_URL
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

# Check if the namespace exists
echo "Checking if the namespace $NAMESPACE exists..."
kubectl get namespace $NAMESPACE > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Namespace $NAMESPACE already exists. Skipping installation."
else
    echo "Namespace $NAMESPACE does not exist. Proceeding with installation..."

    # Install external-secrets using Helm
    echo "Installing external-secrets with some required CRDs..."
    helm install $RELEASE_NAME external-secrets/external-secrets --namespace $NAMESPACE --create-namespace --set installCRDs=true

    if [ $? -ne 0 ]; then
        echo "Failed to install external-secrets."
        exit 1
    fi
fi

# Deploy external-secrets.yaml and secret-store.yaml
echo "Deploying external-secrets.yaml and secret-store.yaml"
kubectl create -f jfrogdb-externalsecrets.yaml
kubectl create -f jfrogdb-secretstore.yaml

if [ $? -eq 0 ]; then
    echo "Successfully deployed external-secrets and secret-store."
else
    echo "Failed to deploy external-secrets and secret-store."
    exit 1
fi

echo "All tasks completed successfully."
