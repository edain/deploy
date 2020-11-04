#!/usr/bin/env bash
cd $(dirname $0)

docker-compose --host 'ssh://root@127.0.0.1' up -d
