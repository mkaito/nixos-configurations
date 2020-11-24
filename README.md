# Server configuration

This repository contains the configuration for my server, Stargazer.

FQDN `stargazer.mkaito.net`

## Services

* Email
* Gitolite
* File hosting
* Minecraft
* Factorio
* Dust discord bot
* Some statefully declared VMs with libvirtd

## Nota bene

If for some reason you decide to dig through the git history of this repository,
you will find there used to be hardcoded secrets, passwords, tokens. These have
all been rotated or deleted. Feel free to try and prove me wrong :wink:

Normally, one would rewrite git history to remove these. I've decided to leave
history intact, as a reminder of how foolish I used to be.

## Deployment

The tool used is [`deploy-rs`](https://github.com/serokell/deploy-rs/). The
deployment itself is described in the `deploy` output property in `flake.nix`.

The `deploy` command is available in `devShell` (`nix develop` or `nix-shell`),
along with a recent version of `nix`. Since we use flakes, we need
`nixUnstable`, but the version in `nixpkgs` is often broken. We build our own
off git master.

Calling `deploy` with no arguments defaults to deploying everything. You may
define a node (server) as `deploy .#server`, and a specific profile in a node as
`deploy .#server.profile`. The names of nodes and profiles are defined in
`flake.nix`.

## Development

A recent build of `nix` with flake support is available in `devShell`.

If you add a new file, you need to `git add` it, or nix won't pick it up. This
is because `nix flake` assumes it works in the context of a git repo.

Running `nix flake check` will evaluate and build all outputs in the flake. This
includes server configurations. Any extra tests in the `checks` output are also
built.

### Deployment to a local QEMU VM

You can build the system closure in the context of a QEMU VM instead of a
top-level system, and then run it directly.

Bear in mind that the server configuration has some expectations for certain
files to exist, specifically in `/root/secrets`. Any services that rely on such
files will fail.

Since the server configuration uses hardcoded values for filesystems and network
configuration that would not work in a VM, there are 2 configurations.

`stargazer` builds the server closure for deployment, and `stargazer-vm` builds
it without these hardcoded values, but with a shim to allow it to work in a VM.

```
$ nix build .#nixosConfigurations.stargazer-vm.config.system.build.vm
$ QEMU_NET_OPTS=hostfwd=tcp::2221-:22 ./result/bin/run-nixos-rm
```

You can SSH into the server with `ssh localhost -p 2221`. Users and SSH keys on
the server are as defined in the configuration.
