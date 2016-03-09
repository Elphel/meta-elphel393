DESCRIPTION = "Elphel NC 393 image (based on core-image-minimal)."

IMAGE_INSTALL = "packagegroup-core-boot ${ROOTFS_PKGMANAGE_BOOTSTRAP} ${CORE_IMAGE_EXTRA_INSTALL}"

# remove not needed ipkg informations
IMAGE_INSTALL_append = "u-boot-ezynq"
IMAGE_INSTALL_append += " python-core \
                         python-numpy \
                         elphel-python-extensions \
                         htop \
                         i2c-tools \
                         mtd-utils \
                         mtd-utils-misc \
                         mtd-utils-ubifs \
                         hdparm \
                         ethtool \
                         net-tools \
                         ntp \
                         sntp \
                         ntpdate \
                         openssh \
                         nano \
                         tree \
                         lighttpd \
                         lighttpd-module-fastcgi \
                         lighttpd-module-cgi \
                         apache2 \
                         php-cgi \
                         php-cli \
                         smartmontools \
                         init-elphel393"
                        
#kernel-modules

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE = "262144"

#IMAGE_FSTYPES = "ext2.gz ext2.gz.u-boot tar.gz"
#IMAGE_FSTYPES = "ext2.gz.u-boot tar.gz"
IMAGE_FSTYPES = "tar.gz ubi"

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
    if not os.path.isdir("${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}"):
        os.system("mkdir ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}")
    if os.path.isfile("${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_ROOTFS}"):
        os.system("rm ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_ROOTFS}")
    os.system("cp ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.ext2.gz.u-boot ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_ROOTFS}")
}
