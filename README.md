# Namespaces

This repository provides a set of C programs for exploring Linux namespaces. It starts out in a very basic form, implementing isolation via a PID namespace, and culminates in the implementation of a very basic container using a number of namespaces and a chroot filesystem. It's purpose is purely to demonstrate the use and effects of Linux namespaces, and is not meant for any other purpose. Head over to [Docker](https://github.com/docker/docker), [LXC](https://github.com/lxc/lxc) or [Rocket](https://github.com/coreos/rocket) for industrial strength container capabilities.

The source code was generated as part of some [blog articles](http://windsock.io) I wrote on namespaces.

## Source Specifics

- `invoke_ns1.c`: PID namespace
- `invoke_ns2.c`: PID, MNT namespaces
- `invoke_ns3.c`: PID, MNT, UTS namespaces
- `invoke_ns4.c`: PID, MNT, UTS, NET namespaces
- `invoke_ns5.c`: PID, MNT, UTS, NET, IPC namespaces
- `invoke_ns6.c`: PID, MNT, UTS, NET, IPC namespaces + chroot jail

`invoke_ns5.c` and `invoke_n6c.c` need to be compiled with the POSIX real time shared library (`-lrt`) linked, in order to access the message queue API. Help for running the variations of the program can be found with the `-h` option, e.g.:

```
# ./invoke_ns -h
Options can be:
    -h           display this help message
    -v           display verbose messages
    -p           new PID namespace
    -m           new MNT namespace
    -u hostname  new UTS namespace with associated hostname
```

## Shared Library Dependencies

In order to create a basic, minimal operating environment for a container, binaries and their shared libraries need to be copied to a directory within the root of the chroot jail. The `binlibdepcp.sh` script provides this capability:

```
# ./binlibdepcp.sh -h
Useage:
 binlibdepcp.sh -h
 binlibdepcp.sh [-n] <full path of binary> <target directory>

Option:
 -h   print this help text
 -n   noclobber, i.e. skip overwrite of existing file

```

## OS X and Windows

Namespaces are only available in the Linux kernel at present, so it's not possible to use these programs natively in either of these environments. The repository also contains, however, the means for creating a very minimal Linux virtual machine with the namespace source code files embedded, which enables OS X and Windows users to try out namespaces.

The repo provides an ISO image of a minimal Linux environment based on the [Tiny Core Linux distribution](http://distro.ibiblio.org/tinycorelinux/), which is approximately 50Mb in size, and is designed to be run from initramfs. It requires VirtualBox to be installed on the OS X or Windows platform. Create a minimally configured generic Linux 2.6/3/x (64 bit) VM, set networking to 'Bridged Adapter', and attach the ISO to the logical CD/DVD drive, before starting the VM.

## Tiny Core Linux ISO

The Tiny Core Linux ISO has been created with just enough for compiling and using the namespace source files, which are located at `/usr/local/src/namespaces` in the image. The ISO is configured with the OpenSSH server, and you may find it useful to connect to the VM using an SSH client. If so, you'll need to set a password for the default user, which is `tc`, in the VM.

The image has a UK keyboard specified as default. If you need to change this, or add any more packages or change the configuration of the image in any other way, you can do this by editing the Dockerfile provided, building the Docker image, and running a container to produce a revised ISO (assumes you have [Docker installed](https://docs.docker.com/installation/)).

After cloning the repo and making the preferred changes to the Dockerfile, execute the following:

```
# docker build -t tinycorelinux .
# docker run --rm tinycorelinux > tinycorelinux.iso
```
