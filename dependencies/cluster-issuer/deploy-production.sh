#!/usr/bin/env bash
cd $(dirname $0)

helm upgrade cluster-issuer . \
  --install \
  --namespace cert-manager \
  --set name=letsencrypt-production \
  --set server=https://acme-v02.api.letsencrypt.org/directory \
  --set email=someone@somewhere.com
