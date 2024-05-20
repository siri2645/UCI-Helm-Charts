#!/bin/bash

# Define the manifest file path
MANIFEST_FILE="aws-credentials.yaml"

# Check if the secret "aws-credentials" exists in the "kube-system" namespace
SECRET_EXISTS=$(kubectl get secret aws-credentials -n kube-system --ignore-not-found)

# Function to install the AWS credentials
install_aws_credentials() {
  echo "AWS credentials not found in the kube-system namespace. Installing..."
  kubectl apply -f $MANIFEST_FILE
  if [ $? -eq 0 ]; then
    echo "AWS credentials successfully installed."
  else
    echo "Failed to install AWS credentials."
    exit 1
  fi
}

# Check if the secret exists and take action
if [ -z "$SECRET_EXISTS" ]; then
  install_aws_credentials
else
  echo "AWS credentials already exist in the kube-system namespace. Exiting."
  exit 0
fi
