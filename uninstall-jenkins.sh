#!/bin/bash
helm uninstall jenkins -n jenkins
kubectl delete ns jenkins