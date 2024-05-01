# `vms-nix`

[![License: Apache-2.0](https://img.shields.io/github/license/ALT-F4-LLC/vms-nix)](./LICENSE)

NixOS-based VM images for ALT-F4 LLC. These images are built using
[nixos-generators](https://github.com/nix-community/nixos-generators) and
Nix flakes.

## Image Details

Every image built from this repository is built with an immutable main disk.
This means that while 'state' directories (`/home`, `/var/lib`, etc.) are
writable, the majority of configuration will be static and immutable, packaged
as part of the Nix store.

There is also an `altf4` user baked into all images that has a list of trusted
SSH keys on it. This user is for administrative purposes. 

> ![NOTE]
> On AMIs, the SSH keypair for `altf4` will not be overridden by setting the
> SSH Key Pair option when provisioning the AMI. That option only applies to
> the `root` user.

## Layout

Service configuration files land in `modules/mixins`, and generic (global)
configuration files land in `modules/profiles`, as they are not tied to any
specific kind or role of image.

```
vms-nix
├── flake.lock
├── flake.nix
├── justfile
├── LICENSE
├── modules
│   ├── mixins
│   │   └── Service configuration modules
│   │       └── default.nix
│   └── profiles
│       └── "Base" configuration modules (EC2 extras, base config, etc)
└── README.md
```

## Building an Image

To build an image, find its package name in [`flake.nix`](./flake.nix), then
use `just build` to build it;

```
$ just build ecs-node
```

### Publishing an AMI to EC2

> ![NOTE]
> Using this if you're not a member of ALT-F4 requires some more steps. See
> [`aws/README.md`](./aws/README.md) for more info.

There is a `just` task for doing this called `publish-ami`. It takes the name
of the image you want to build as an input, and then carries out the following
tasks:

- Builds the image with `just build`
- Uploads the output `.vhd` image to S3
- Kicks off a snapshot import using the EC2 VM Import/Export service
- Waits for the snapshot to be fully imported and available
- Registers an AMI using the snapshot and outputs its ID

NixOS VMs use `/dev/sda1` as their root device name, and that is configured at
the point the AMI is registered. By default, the images are built on a 4GB disk
but this can be tweaked if an image does not fit into only 4GB.

All VMs are also configured with the `cachix-agent` installed, and all Amazon
AMIs are configured with `amazon-ssm-agent` and `amazon-init` to ensure full
feature compatibility with EC2.

## Contributing

While this is an internal project at ALT-F4, we still welcome contributions
from the community in case you can spot an improvement or a suggestion!

Feel free to raise PRs and issues against this repository, but also understand
that as this is an internal piece of tooling, some opinionations in configs
and/or logic will be present and we may be stubborn with them!

## License

`vms-nix` is licensed under the Apache License Version 2.0. For full license
terms, see [`LICENSE`](./LICENSE).
