#!/usr/bin/env bash


# account 958397265706
# region eu-west-2

account_id=$1
region=$2

aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${account_id}.dkr.ecr.${region}.amazonaws.com

docker build . -t webapp -f devops-test-main/Dockerfile
docker tag webapp:latest ${account_id}.dkr.ecr.${region}.amazonaws.com/patchwork/webapp:latest
docker push ${account_id}.dkr.ecr.${region}.amazonaws.com/patchwork/webapp:latest
