# Know How

## Tools

### make

Ever remembered all command line options for building an app? You can write one Makefile with shortcuts that will help you remember... I often use:

- clean
- build
- test
- run
- docker

### direnv

Ever built a 12-factor app? You configure some project with environment variables by hand? Stop doing that and start using `.envrc`:

    export somevar=someparam

Now, when entering the directory a first time, you will get asked if you want to allow this `.envrc`:

    direnv: error /Users/stefanjacobs/tmp/.envrc is blocked. Run `direnv allow` to approve its content

After allowing this, the settings in the envrc-File will be integrated in the shells environment when you enter the directory and will be unloaded, when you exit again.

### multipass

With [multipass](https://multipass.run/) you can start an Ubuntu linux instance in a matter of seconds. Multipass can launch and run virtual machines and configure them with cloud-init like a public cloud. Prototype your cloud launches locally for free. What is really nice is that networking is enabled between all instances, so you may build multi-node Kubernetes clusters, see e.g. [Tutorial 2: Kubernetes with Multipass](../02-kube-multipass).

### kubectx/kubens

When working with kubernetes you can use [kubectx](https://github.com/ahmetb/kubectx) to switch the Kubernetes context (if there are more than one in your current kube-config). Using `kubens` you can choose the namespace you are working on.

## Websites

There are some good to know websites for development.

### lvh.me

[lvh.me](https://lvh.me/): Always points to localhost. There are some [other sites available](https://gist.github.com/tinogomes/c425aa2a56d289f16a1f4fcb8a65ea65).

### nip.io

[nip.io](https://nip.io/): `192-168-64-11.nip.io` points to 192.168.64.11. No more editing of hosts.txt!
