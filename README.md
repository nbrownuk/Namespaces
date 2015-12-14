# Namespaces

This repository provides a set of C programs for exploring Linux namespaces. It starts out in a very basic form, implementing isolation via a PID namespace, and culminates in the implementation of a very basic container using a number of namespaces and a chroot filesystem. It's purpose is purely to demonstrate the use and effects of Linux namespaces, and is not meant for any other purpose. Head over to [Docker](https://github.com/docker/docker), [LXC](https://github.com/lxc/lxc) or [rkt](https://github.com/coreos/rocket) for industrial strength container capabilities.

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
Usage: ./invoke_ns [options] [cmd [arg...]]
Options can be:
    -h           display this help message
    -v           display verbose messages
    -p           new PID namespace
    -m           new MNT namespace
    -u hostname  new UTS namespace with associated hostname
    -n           new NET namespace
    -i no|yes    create message queue in new IPC namespace (yes), or default namespace (no):
    -c dir       jail process in specified directory
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
