#!/usr/bin/env bash
cd $(dirname $0)

kubectl create namespace ingress-nginx

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
  --install \
  --namespace ingress-nginx \
  --set defaultBackend.enabled=false
