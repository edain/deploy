#!/usr/bin/env bash
cd $(dirname $0)

kubectl create namespace redis

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade redis bitnami/redis \
  --install \
  --namespace redis
