#!/bin/bash

set -x

helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
kubectl create ns sonarqube
helm upgrade --install sonarqube sonarqube/sonarqube -n sonarqube --values sonar-values.yaml
