#!/bin/bash

# Check if the AWS EBS CSI driver pods exist in the kube-system namespace
PODS_EXIST=$(kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver --ignore-not-found)

# Function to install the AWS EBS CSI driver using Helm
install_aws_ebs_csi_driver() {
  echo "AWS EBS CSI driver not found in the kube-system namespace. Installing..."

  # Check if the aws-ebs-csi-driver repo is already added
  HELM_REPO_EXIST=$(helm repo list | grep aws-ebs-csi-driver)
  if [ -z "$HELM_REPO_EXIST" ]; then
    echo "Adding Helm repository for AWS EBS CSI driver..."
    helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
    if [ $? -ne 0 ]; then
      echo "Failed to add Helm repository."
      exit 1
    fi
  else
    echo "Helm repository for AWS EBS CSI driver is already added."
  fi

  # Update the Helm repository
  helm repo update
  if [ $? -ne 0 ]; then
    echo "Failed to update Helm repository."
    exit 1
  fi

  # Install the AWS EBS CSI driver
  helm upgrade --install aws-ebs-csi-driver --namespace kube-system aws-ebs-csi-driver/aws-ebs-csi-driver
  if [ $? -eq 0 ]; then
    echo "AWS EBS CSI driver successfully installed."
  else
    echo "Failed to install AWS EBS CSI driver."
    exit 1
  fi
}

# Check if the pods exist and take action
if [ -z "$PODS_EXIST" ]; then
  install_aws_ebs_csi_driver
else
  echo "AWS EBS CSI driver already exists in the kube-system namespace. Exiting."
  exit 0
fi
