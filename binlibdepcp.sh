#!/bin/bash

# title          : binlibdepcp.sh
# description    : This script copies a binary and its dependent libraries to a
#                  target location, retaining the relevant directory structure.
#                  The script can be used to prepare chroot jail environments.
# author         : Nigel Brown
# date           : 17-Mar-2015
# version        : 1.0
# usage          : bash binlibdepcp.sh <binary> <target>
# notes          : 
# bash_version   : GNU bash, version 4.3.11(1)-release (x86_64-pc-linux-gnu)
# ============================================================================ #

set -e

NOCLOBBER=false

usage () {
    echo "Useage:"
    echo " `basename $0` -h"
    echo " `basename $0` [-n] <full path of binary> <target directory>"
    echo
    echo "Option:"
    echo " -h   print this help text"
    echo " -n   noclobber, i.e. skip overwrite of existing file"
}

# If it's simply a request for help, print the usage and exit
if [ "$#" -eq 1 -a "$1" = "-h" ]; then
    usage
    exit 0
fi    

# Otherwise, check for correct number of arguments
if [ "$#" -lt 2 -o "$#" -gt 3 ]; then
    usage >&2
    exit 2
else
    while getopts ":n" opt; do
        case $opt in
            n)
              NOCLOBBER=true
              ;;
            \?)
              usage >&2
              exit 2
              ;;
        esac
    done
    shift $((OPTIND - 1))
    BINARY="$1" && TARGET="$2"
fi

# Exit if the binary cannot be found at $BINARY, or is not readable
if [ ! -f "$BINARY" -o ! -r "$BINARY" ]; then
    echo "$BINARY: not accessible ...... aborting" >&2
    exit 1
fi

# Test to see if target directory exists, and if it does,
# it is not a regular file, and create it if not (if permissable)
if [ ! -d "$TARGET" -o ! -w "$TARGET" ]; then
    if [ -f "$TARGET" ]; then
        echo "$TARGET: a regular file of this name already exists ...... aborting" >&2
        exit 1
    fi
    if [ -d "$TARGET" -a ! -w "$TARGET" ]; then
        echo "$TARGET: no write permission on directory ...... aborting" >&2
        exit 1
    fi
    EXISTING_DIR="$TARGET"
    while [ ! -d "$EXISTING_DIR" ]
    do
        EXISTING_DIR="$(dirname "$EXISTING_DIR")"
    done
    if [ ! -w "$EXISTING_DIR" ]; then
        echo "$TARGET: no write permission at $EXISTING_DIR ...... aborting" >&2
        exit 1 
    else
        mkdir -p "$TARGET"
    fi
fi    

printf "Copying ...\n\n"

# Copy the binary to the target, retaining the full path name. NB don't
# use --parents, it's not supported by BusyBox
printf "%25s : " $(basename $BINARY | cut -c1-25)
if [ ! -d "${TARGET}$(dirname $BINARY)" ]; then
    mkdir -p "${TARGET}$(dirname $BINARY)"
fi
if [ -f "${TARGET}${BINARY}" -a "$NOCLOBBER" = true ]; then
    printf "[SKIPPED]\n"
else
    cp -p "$BINARY" "${TARGET}$(dirname $BINARY)"
    printf "[OK]\n"
fi    

# Copy the libs to the target, retaining the full path name. NB don't
# use --parents, it's not supported by BusyBox
LIBS=$(ldd $BINARY | cut -d'>' -f2 | grep /lib | awk '{print $1}')
if [ -n "$LIBS" ]; then
    for LIB in $LIBS ; do
        printf "%25s : " $(basename $LIB | cut -c1-25)
        if [ ! -d "${TARGET}$(dirname $LIB)" ]; then
            mkdir -p "${TARGET}$(dirname $LIB)"
        fi
        if [ -f "${TARGET}${LIB}" -a "$NOCLOBBER" = true ]; then
            printf "[SKIPPED]\n" 
        else
            cp -p "$LIB" "${TARGET}$(dirname $LIB)"
            printf "[OK]\n"
        fi
    done
fi

# Copy shared library cache to the target
if [ -f /etc/ld.so.cache -a -n "$LIBS" ]; then
    printf "%25s : " $(echo "ld.so.cache")
    if [ ! -d ${TARGET}/etc ]; then
        mkdir -p ${TARGET}/etc
    fi
    if [ -f "${TARGET}/etc/ld.so.cache" -a "$NOCLOBBER" = true ]; then
        printf "[SKIPPED]\n"
    else
        cp -p /etc/ld.so.cache "${TARGET}/etc/ld.so.cache"
        printf "[OK]\n"
    fi
fi

printf "\n...... Done\n"

exit 0
