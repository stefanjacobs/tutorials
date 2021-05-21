# docker-from-scratch

Demonstrates the `FROM scratch` paradigm for docker.

## Documentation

If you are able to build a statically linked binary, e.g. GO executables, you can easily build a docker image `FROM scratch` meaning that you do not need the stuff that a base images, for example Alpine, brings.

This small PoC demonstrates the capability of Docker to build images from scratch. This means that the only image layer is purely the application itself and nothing else that it depends on. This leads to very small images compared to Alpine or Debian-Slim. Additionally is the attack vector on those images much smaller, because there is nothing else in it - not even a shell.

Please note the `Dockerfile` and the special `FROM scratch` directive:

    FROM scratch
    COPY hello hello 
    CMD ["./hello"]

The second line copies the webserver into the image, and the third line defines the command that is executed as soon as a container is started. It is important to use syntax `CMD ["", "", ...]` such that the process gets the PID 1 and because of that the shutdown signals `SIGTERM` and `SIGKILL`.

## Usage/Example

Local execution with

    make go-run

You can curl now the endpoint as in the following example:

    $ make go-run &
    go run hello.go
    Welcome, user! Curl me (locally with Port 8080) with your name as path :-D

    $ curl localhost:8080/TutorialHero
    Hello, TutorialHero!

Build the binary for linux and amd64 architecture with

    make go-build

Build a docker image from scratch with

    make docker-build

And execute the docker container with

    make docker-run

Alternatively you can push the image to an image registry, here the one that we created in demo 03 with

    make docker-push

and deploy the service to the k3s cluster we created in demo 02 using

    make kubernetes-apply

Cleanup can be done with

    make clean

and for cleanup kubernetes you may use

    make kubernetes-delete

## Authors

- [@stefanjacobs](https://git.tech.rz.db.de/StefanJacobs)
