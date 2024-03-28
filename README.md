# hsg-project

Docker repo for HSG project

## Build and run Dockerfile on your local machine

1. build: `docker build --no-cache -t hsg-project .`
2. run: `docker run -p 8080:8080 hsg-project`

## Build and publish new Docker image

* Docker Hub: https://hub.docker.com/r/joewiz/hsg-project

1. `docker buildx build --platform linux/amd64,linux/arm64 -t joewiz/hsg-project:latest .`
2. `docker push joewiz/hsg-project:latest`

or in one command: 

1. `docker buildx build . --platform linux/amd64,linux/arm64 -t joewiz/hsg-project:latest --push`