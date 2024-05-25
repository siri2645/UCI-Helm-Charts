#!/bin/bash
helm uninstall sonarqube -n sonarqube
kubectl delete ns sonarqube
