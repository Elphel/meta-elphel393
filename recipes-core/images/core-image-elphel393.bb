DESCRIPTION = "Elphel NC 393 image (based on core-image-minimal)."

IMAGE_INSTALL = "packagegroup-core-boot ${ROOTFS_PKGMANAGE_BOOTSTRAP} ${CORE_IMAGE_EXTRA_INSTALL}"

#IMAGE_FEATURES = "read-only-rootfs"

# remove not needed ipkg informations
IMAGE_INSTALL_append = "u-boot-ezynq"
IMAGE_INSTALL_append += " \
                         sudo \
                         gcc \
                         coreutils \
                         python-core \
                         python-numpy \
                         python-argparse \
                         python-json \
                         python-xml \
                         elphel-python-extensions \
                         htop \
                         rsync \
                         i2c-tools \
                         mtd-utils \
                         mtd-utils-misc \
                         mtd-utils-ubifs \
                         hdparm \
                         parted \
                         ethtool \
                         net-tools \
                         nfs-utils-client \
                         ntp \
                         sntp \
                         ntpdate \
                         openssh \
                         nano \
                         tree \
                         lighttpd \
                         lighttpd-module-fastcgi \
                         lighttpd-module-cgi \
                         lighttpd-module-setenv \
                         apache2 \
                         perl \
                         php-cgi \
                         php-cli \
                         libsjs \
                         smartmontools \
                         apps-camogm \
                         apps-imgsrv \
                         apps-autocampars \
                         apps-autoexposure \
                         apps-editconf \
                         apps-histograms \
                         apps-tempmon \
                         apps-gps \
                         apps-astreamer \
                         web-393 \
                         web-camvc \
                         web-hwmon \
                         iw \
                         wpa-supplicant \
                         dhcp-client \
                         dhcpcd \
                         linux-firmware-rtl8192cu \
                         init \
                         overlay-sync \
                         udev-rules \
                         e2fsprogs \
                         dosfstools \
                         gstreamer1.0 \
                         fpga-x393 \
                         fpga-x393sata \
                         fpga-x359 \
                         alsa-utils \
                         zip \
                         wget \
                         u-boot-fw-utils \
                        "

# gstreamer1.0-plugins-base \
# gstreamer1.0-plugins-good \
# gstreamer1.0-plugins-bad \
# gstreamer1.0-rtsp-server \
# opencv-apps \
# python-opencv \
#

inherit extrausers
EXTRA_USERS_PARAMS = "\
                        useradd -P pass elphel;\
                        usermod -P pass root;\
                    "

#kernel-modules
IMAGE_INSTALL_append += " kernel-module-ahci-elphel \
                        "
IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE = "262144"

#IMAGE_FSTYPES = "ext2.gz ext2.gz.u-boot tar.gz"
#IMAGE_FSTYPES = "ext2.gz.u-boot tar.gz"
IMAGE_FSTYPES = "tar.gz ubi ext4"

########################################################################
########################################################################
## root@elphel393:~# mtdinfo /dev/mtd4 -u
## mtd4
## Name:                           rootfs
## Type:                           nand
## Eraseblock size:                131072 bytes, 128.0 KiB
## Amount of eraseblocks:          2048 (268435456 bytes, 256.0 MiB)
## Minimum input/output unit size: 2048 bytes
## Sub-page size:                  2048 bytes
## OOB size:                       64 bytes
## Character device major/minor:   90:8
## Bad blocks are allowed:         true
## Device is writable:             true
## Default UBI VID header offset:  2048
## Default UBI data offset:        4096
## Default UBI LEB size:           126976 bytes, 124.0 KiB
## Maximum UBI volumes count:      128
########################################################################
########################################################################

MKUBIFS_ARGS = " -m 2048 -e 126976 -c 2048"
UBINIZE_ARGS = " -m 2048 -p 128KiB -s 2048"

create_symlinks_append(){

    rlocs = (d.getVar('PRODUCTION_ROOT_LOCATION', True)).split()
    for rloc in rlocs:
        if not os.path.isdir("${DEPLOY_DIR_IMAGE}/"+rloc):
            os.system("mkdir ${DEPLOY_DIR_IMAGE}/"+rloc)

        if (rloc=="mmc"):
            image_ext = ".tar.gz"
            image_ext2 = ""
        else:
            image_ext = ".ubifs"
            image_ext2 = ".ubi"

        if os.path.isfile("${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs"+image_ext):
            tmp_fname = "${DEPLOY_DIR_IMAGE}/"+rloc+"/${PRODUCTION_ROOTFS}"+image_ext
            if os.path.isfile(tmp_fname):
                os.system("rm "+tmp_fname)
            os.system("cp ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs"+image_ext+" "+tmp_fname)

        if not image_ext2=="":
          if os.path.isfile("${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs"+image_ext2):
              tmp_fname = "${DEPLOY_DIR_IMAGE}/"+rloc+"/${PRODUCTION_ROOTFS}"+image_ext2
              if os.path.isfile(tmp_fname):
                  os.system("rm "+tmp_fname)
              os.system("cp ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs"+image_ext2+" "+tmp_fname)
}
