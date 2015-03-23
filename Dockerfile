FROM debian:jessie

MAINTAINER Nigel Brown <nigel@windsock.io>

# Install some required tools for building the ISO
RUN apt-get update && \
    apt-get -y install bash \
                       wget \
                       xorriso \
                       cpio && \
    rm -rf /var/lib/apt/lists/*

# Set some variables
ENV VERSION       6.1
ENV TCL_REPO_BASE http://distro.ibiblio.org/tinycorelinux/6.x/x86
ENV ISO_ROOT      /tmp/iso
ENV ROOTFS        /rootfs
ENV EXTENSIONS    bash.tcz \
                  compiletc.tcz \
                  iproute2.tcz \
                  kmaps.tcz \
                  openssh.tcz

# Download and extract the Tiny Core Distro
RUN /bin/bash -c "mkdir -p $ROOTFS dist/{iso,tcz,dep} ${ISO_ROOT}/cde/optional" && \
    wget -nv -L "${TCL_REPO_BASE}/release/Core-${VERSION}.iso" -O "dist/iso/Core-${VERSION}.iso" && \
    xorriso -osirrox on -indev "dist/iso/Core-${VERSION}.iso" -extract / $ISO_ROOT

# Extract root filesystem to $ROOTFS
RUN cd $ROOTFS && \
    zcat $ISO_ROOT/boot/core.gz | cpio -idv && \
    cd -

# Inject namespace lab files
COPY src ${ROOTFS}/usr/local/src/namespaces/
    
# Inject custom OS files and customisations into rootfs
RUN chown -R 1001:50 ${ROOTFS}/usr/local/src/namespaces && \
    echo "loadkmap < /usr/share/kmap/qwerty/uk.kmap" >> ${ROOTFS}/opt/bootlocal.sh && \
    echo "/usr/local/etc/init.d/openssh start &" >> ${ROOTFS}/opt/bootlocal.sh

# Rebuild rootfs and replace in ISO tree
RUN cd $ROOTFS && \
    find | cpio -o -H newc | gzip -2 > "${ISO_ROOT}/boot/core.gz" && \
    cd -

# Add the specified extensions to load on boot
RUN while [ -n "${EXTENSIONS}" ]; do \
        DEPS="" && \
        for EXTENSION in ${EXTENSIONS}; do \
            [ -f "dist/tcz/${EXTENSION}" ] || wget -nv -L "${TCL_REPO_BASE}/tcz/${EXTENSION}" -O "dist/tcz/${EXTENSION}" && \
            [ -f "dist/tcz/${EXTENSION}.dep" ] || wget -nv -L ${TCL_REPO_BASE}/tcz/${EXTENSION}.dep -O "dist/dep/${EXTENSION}.dep" || touch "dist/dep/${EXTENSION}.dep" && \
            cp "dist/tcz/${EXTENSION}" "${ISO_ROOT}/cde/optional" && \
            DEPS=$(echo ${DEPS} | cat - "dist/dep/${EXTENSION}.dep" | sort -u); \
        done && \
        EXTENSIONS=$DEPS; \
    done && \
    ls ${ISO_ROOT}/cde/optional | tee ${ISO_ROOT}/cde/onboot.lst > ${ISO_ROOT}/cde/copy2fs.lst

RUN sed -i 's/prompt 1/prompt 0/' "${ISO_ROOT}/boot/isolinux/isolinux.cfg"
RUN sed -i "s/append/append cde /" "${ISO_ROOT}/boot/isolinux/isolinux.cfg"

COPY make_iso.sh /

RUN /make_iso.sh

CMD ["cat", "tinycorelinux.iso"]
