#! /bin/bash

xorriso -as mkisofs \
        -l -J -R -V "Tiny Core Linux ${VERSION}" \
        -b boot/isolinux/isolinux.bin \
        -boot-load-size 4 \
        -c boot/isolinux/boot.cat \
        -boot-info-table \
        -no-emul-boot \
        -o /tinycorelinux.iso "${ISO_ROOT}"
