#!/usr/bin/env bash

IMAGE_TAG=${1:latest}

helm upgrade --namespace terria --install --timeout 9999s terria deploy/helm/terria -f deploy/helm/wsp-deploy-test.yml --set "terriamap.image.full=940728446396.dkr.ecr.ap-southeast-2.amazonaws.com/terria-test:${IMAGE_TAG}"
