#!/usr/bin/env bash
cd $(dirname $0)

kubectl create namespace cert-manager

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade cert-manager jetstack/cert-manager \
  --install \
  --namespace cert-manager \
  --version v1.0.3 \
  --set installCRDs=true
