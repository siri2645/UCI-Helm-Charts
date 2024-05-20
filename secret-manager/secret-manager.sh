#!/bin/bash

echo "Before executing this script need to create Identity Provider for our cluster and make it has thump printed"
echo " "
echo "Now executing another script to create role and so on..."
sh role-policy.sh

HELM_REPO_EXIST=$(helm repo list | grep secret-store-csi-driver)
  if [ -z "$HELM_REPO_EXIST" ]; then
    echo "Adding Helm repository for secret-store-csi-driver..."
    helm repo add secret-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
    if [ $? -ne 0 ]; then
      echo "Failed to add Helm repository."
      exit 1
    fi
  else
    echo "Helm repository for secret-store-csi-driver is already added."
  fi

    # Update the Helm repository
  helm repo update
  if [ $? -ne 0 ]; then
    echo "Failed to update Helm repository."
    exit 1
  fi

  # Install secrets-store-csi-driver with enableSecretRotation=true
  echo "Installing secrets-store-csi-driver with enableSecretRotation=true" 
  helm upgrade --install secrets-store-csi-driver secret-store-csi-driver/secrets-store-csi-driver --version 1.4.3 -n kube-system --set enableSecretRotation=true
  if [ $? -eq 0 ]; then
    echo "AWS secrets-store-csi-driver successfully installed."
  else
    echo "Failed to install AWS secrets-store-csi-driver"
    exit 1
  fi

echo "Installing aws-provider-installer, this will help to pull secrets to csi drivers" 
kubectl apply -f aws-provider-installer/

kubectl apply -f secret-provider-class.yaml
