#!/bin/bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --create-namespace --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --values ./values-prod.yaml