DESCRIPTION = "Elphel NC 393 image (based on core-image-minimal)."

IMAGE_INSTALL = "packagegroup-core-boot ${ROOTFS_PKGMANAGE_BOOTSTRAP} ${CORE_IMAGE_EXTRA_INSTALL}"

# remove not needed ipkg informations
IMAGE_INSTALL_append = " python-core \
                        i2c-tools \
                        mtd-utils \
                        ethtool \
                        openssh \
                        net-tools \
                        modphp \
                        apache2 \
                        php-cli"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE = "65536"
