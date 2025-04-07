#!/bin/bash
tag_name="hello_world_docker"
ecr_arn="741448928264.dkr.ecr.us-east-1.amazonaws.com"
set -e
echo "Starting Gradle build..."
./gradlew build
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ecr_arn
docker buildx build --platform linux/amd64 --load -t hello_world_docker .
docker run $tag_name
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ecr_arn
docker tag $tag_name:latest $ecr_arn/sandbox:hello-world
docker push $ecr_arn/sandbox:hello-world
cd terraform
terraform apply --auto-approve