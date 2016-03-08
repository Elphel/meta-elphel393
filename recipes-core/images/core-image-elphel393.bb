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

#IMAGE_FSTYPES = "jffs2 ext2.gz"

create_symlinks_append(){
    if not os.path.isdir("${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}"):
        os.system("mkdir ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}")
    if os.path.isfile("${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_ROOTFS}"):
        os.system("rm ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_ROOTFS}")
    os.system("cp ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.ext2.gz.u-boot ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_ROOTFS}")
}
