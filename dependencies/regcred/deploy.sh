#!/usr/bin/env bash
cd $(dirname $0)

kubectl create secret docker-registry regcred \
  -n app \
  --docker-server="https://index.docker.io/v1/"  \
  --docker-username="someone" \
  --docker-password="password" \
  --docker-email="someone@somewhere.com"
