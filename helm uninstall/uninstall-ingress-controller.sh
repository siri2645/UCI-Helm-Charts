#!/bin/bash
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete ns ingress-nginx