#!/bin/bash
kubectl create -f ./gp2-encrypted-sc.yaml
kubectl delete sc gp2
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade --create-namespace --install install jenkins jenkins/jenkins -n jenkins --values ./values-prod.yaml