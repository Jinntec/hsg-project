# hsg-project

Docker repo for HSG project

## Build and run Dockerfile on your local machine

1. build: `docker build -t hsg-project .`
2. run: `docker run -p 8080:8080 hsg-project`

## Build and publish new Docker image

* Docker Hub: https://hub.docker.com/r/joewiz/hsg-project

Publishing docker images is automated via CI. Publishing from local environments is strongly discouraged. If you need to push from a local environment to the docker hub registry separate caches for `arm` and `x86` are necessary. The default `buildchache` is not in use on CI.

Building multi-arch images without a recent build cache is slow. 

```shell
docker buildx build --platform linux/arm64 --cache-from joewiz/hsg-project:buildcache-arm -t joewiz/hsg-project .
docker buildx build --platform linux/amd64 --cache-from joewiz/hsg-project:buildcache-x86 -t joewiz/hsg-project .
docker buildx build --platform linux/amd64,linux/arm64 -t joewiz/hsg-project --cache-to joewiz/hsg-project:buildcache-x86 --cache-to joewiz/hsg-project:buildcache-arm --push.
```