#!/bin/bash

helm repo add jfrog https://charts.jfrog.io
helm repo update

export MASTER_KEY=$(openssl rand -hex 32) 
echo ${MASTER_KEY}

export JOIN_KEY=$(openssl rand -hex 32)
echo ${JOIN_KEY}

helm upgrade --install artifactory --set artifactory.replicaCount=3 --set artifactory.masterKey=${MASTER_KEY} --set artifactory.joinKey=${JOIN_KEY} --namespace artifactory --create-namespace jfrog/artifactory
