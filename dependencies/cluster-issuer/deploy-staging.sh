#!/usr/bin/env bash
cd $(dirname $0)

helm upgrade cluster-issuer-staging . \
  --install \
  --namespace cert-manager \
  --set name=letsencrypt-staging \
  --set server=https://acme-staging-v02.api.letsencrypt.org/directory \
  --set email=someone@somewhere.com
