#!/bin/bash

kubectl create -f secret-store-csi-driver/
kubectl create -f aws-provider-installer/
kubectl create -f secret-provider-class.yaml
kubectl patch sts sonarqube-sonarqube -n sonarqube --type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts/-", "value": {"name": "rds-secret-volume", "mountPath": "/mnt/rds-secret", "readOnly": true}}]'
