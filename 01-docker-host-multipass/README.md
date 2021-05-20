# Tutorial: Install Docker(-host) using Multipass

Over the last years I was using [Docker Desktop](https://www.docker.com/products/docker-desktop)
as a 'native' solution for my MacBook. I really liked the integration and easy administration. As
a Kubernetes user I also learned to use the Kubernetes Addon and again the well seamed
integration and ability to switch the Addon on and off.

Over time I learned that the battery consumption and cpu demand is very high and that I
needed a 'better' solution. There were a lot of issues filed
([issue](https://github.com/docker/for-mac/issues/4323),
[issue](https://github.com/docker/for-mac/issues/3499),
[issue](https://github.com/docker/for-mac/issues/1759), ...), and I observed them getting
fixed, but time after time, new issues popped up and it was nowhere possible to let
Docker Desktop run on its own.

Because of that I searched for a better solution that is able to work seamlessly between the shell
and the docker system. I stated the following requirements for myself:

1. Easy switch to turn on and turn off.
2. System independent (Windows, Linux, MacOS should behave more or less the same)
3. Keep CPU and Battery requirements to the minimum

After some web searches and meetings with colleagues we found Multipass that seemed to fulfill
those requirements.

## Precondition

1. Have a packet manager installed:

    - Windows: [chocolatey](https://chocolatey.org/)
    - Linux: [snap](https://snapcraft.io/) or one of the others, there are so many....
    - MacOS: [brew](https://brew.sh/)

2. Install Multipass package using your package manager:

    - Windows: `choco install multipass`
    - Linux: `snap install multipass`
    - MacOs: `brew install multipass`

Now we are ready to roll, so let's get started!

## Create your docker host machine

With Multipass installed we are now ready to start a small ubuntu instance that we name `dockerhost`.
In this article we denote the local shell on the physical machine with `>` and the shell in a virtual
machine is introduced at a later time. I set it to use one cpu, you can tweak those settings, as you
like.

    > multipass launch -c 1 -n dockerhost

After some seconds/minutes you came back to the shell and you see that a new machine was started:

    > multipass ls
    Name                    State             IPv4             Image
    dockerhost              Running           192.168.64.7     Ubuntu 20.04 LTS

Note the IPv4 here for later usage. (You can get it again with `multipass ls` any time. Now you are
able to open a shell in the dockerhost:

    > multipass shell dockerhost
    Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-70-generic x86_64)

     * Documentation:  https://help.ubuntu.com
     * Management:     https://landscape.canonical.com
     * Support:        https://ubuntu.com/advantage

      System information as of Tue Apr  6 14:37:04 CEST 2021

      System load:  0.13              Processes:               114
      Usage of /:   26.8% of 4.67GB   Users logged in:         0
      Memory usage: 18%               IPv4 address for enp0s2: 192.168.64.7
      Swap usage:   0%


    0 update can be installed immediately.
    0 of these updates are security updates.
    To see these additional updates run: apt list --upgradable


    The list of available updates is more than a week old.
    To check for new updates run: sudo apt update

    To run a command as administrator (user "root"), use "sudo <command>".
    See "man sudo_root" for details.

    ubuntu@dockerhost:~$ 

After some output (may look like above) we see a new shell denoted as
`ubuntu@dockerhost:~$` in the following. First let us install docker:

    ubuntu@dockerhost:~$ sudo snap install docker

To get docker running as a dockerhost, we have to do some preliminary work:

    ubuntu@dockerhost:~$ sudo addgroup --system docker; sudo adduser $USER docker; newgrp docker
    ubuntu@dockerhost:~$ sudo snap disable docker; sudo snap enable docker

To activate those changes, you have to log out and log on again. And last but not
least we have to make docker listen on port `2375` for incoming requests:

    ubuntu@dockerhost:~$ sudo vi /var/snap/docker/current/config/daemon.json

The file should look something like the following (be aware that you are opening up your
virtual machine to anyone with access to your network, you can encrypt the endpoint and
enable [authentication](https://docs.docker.com/engine/security/protect-access/), if
you need):

    {
        "hosts": [ "unix:///var/run/docker.sock","tcp://0.0.0.0:2375"],
        "log-level":        "error",
        "storage-driver":   "overlay2"
    }

After changing the file, please restart the docker daemon a last time:

    ubuntu@dockerhost:~$ sudo systemctl restart snap.docker.dockerd

Now everything is set up to use this virtual machine on the physical
machine as a dockerhost. You can shut down and start up the virtual
machine as you like and the docker daemon will restart as well. And
if you do not need it, just stop it - and it will not eat up precious
resources, nice! Well done!

## Setup the host to use the dockerhost

You have to have docker installed (not the daemon oder the server). For MacOS this is e.g.

    > brew install docker

and this will only install the docker executable and no services. You can test your installation
with the command

    > docker ps

It should result in an error like `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`. Only after setting the `DOCKER_HOST` variable you should be able to see results:

    > export DOCKER_HOST="tcp://192.168.64.7:2375"
    > docker ps
    CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

indicating that no containers are running at the moment - what we expected.

## Create shell aliases for easy of use

To have an easy to use dockerhost, I put the following in my bash environment `.bashrc`. Every time I open
a shell, those get loaded into the environment:

    export DOCKER_HOST="tcp://192.168.64.7:2375"
    alias stop-dockerhost='multipass stop dockerhost'
    alias start-dockerhost='multipass start dockerhost'

Yes, well done, good job! This was part 1 of a multipart series of developing locally with Docker and Kubernetes.

## Limitations

At the moment, multipass does not seem to work within a VPN environment.

## Appendix

The whole process is automated in the shell script [createDockerhost.sh](createDockerhost.sh)

## Contact

You can contact me using [Twitter](https://twitter.com/intent/tweet?url=https%3a%2f%2fstefanjacobs.github.io%2ftutorials%2f&text=Developing%20with%20Kubernetes%20and%20Docker%20on%20localhost%20without%20messing%20up%20your%20system&via=stefanjacobs&original_referer=https://stefanjacobs.github.io/tutorials/) (my [profile](https://twitter.com/stefanj78)) or if you have comments regarding this tutorial, visit me on [GitHub](https://github.com/stefanjacobs/tutorials) and file an [issue](https://github.com/stefanjacobs/tutorials/issues) or create a [pull requests](https://github.com/stefanjacobs/tutorials/pulls).

## References

- [Brew](https://brew.sh/)
- [Chocolatey](https://chocolatey.org/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Docker Host Authentication](https://docs.docker.com/engine/security/protect-access/)
- [Snap](https://snapcraft.io/)
