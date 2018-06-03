#!/bin/bash

containerRepositoryName='project-base-api'

# Create container application image with "latest" tag, set "Dockerfile" path,
# change "rails_env_var" variable inside Dockerfile and context path
docker build -t $containerRepositoryName:latest --build-arg bundle_options_var='--without staging production' .

# Execute docker compose to start ala services described in "docker-compose.yml"
# Adding "-d" hide logs. To show logs execute "docker-compose logs"
docker-compose up