#!/bin/bash
set -x
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --create-namespace --install ingress-nginx-1 ingress-nginx/ingress-nginx -n ingress-nginx-1 --values ./values-prod.yaml
