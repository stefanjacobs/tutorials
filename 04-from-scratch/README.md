# docker-from-scratch

Demonstrates the `FROM scratch` paradigm for docker.

## Documentation

If you are able to build a statically linked binary, e.g. GO executables, you can easily build a docker image `FROM scratch` meaning that you do not need the stuff that a base images, for example Alpine, brings.

This small PoC demonstrates the capability of Docker to build images from scratch. This means that the only image layer is purely the application itself and nothing else that it depends on. This leads to very small images compared to Alpine or Debian-Slim. Additionally is the attack vector on those images much smaller, because there is nothing else in it - not even a shell.

## Usage/Example

Local execution with

    make go-run

Build the binary for linux and amd64 architecture with

    make go-build

Build a docker image from scratch with

    make docker-build

And execute the docker container with

    make docker-run

## Authors

- [@stefanjacobs](https://git.tech.rz.db.de/StefanJacobs)
