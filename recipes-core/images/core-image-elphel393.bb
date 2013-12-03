DESCRIPTION = "Elphel NC 393 image (based on core-image-minimal)."

IMAGE_INSTALL = "packagegroup-core-boot ${ROOTFS_PKGMANAGE_BOOTSTRAP} ${CORE_IMAGE_EXTRA_INSTALL}"

# remove not needed ipkg informations
IMAGE_INSTALL_append = " python-core \
                         htop \
                         i2c-tools \
                         mtd-utils \
                         ethtool \
                         net-tools \
                         ntp \
                         sntp \
                         openssh \
                         nano \
                         lighttpd \
                         lighttpd-module-fastcgi \
                         lighttpd-module-cgi \
                         modphp \
                         apache2 \
                         php-cgi \
                         php-cli \
                         init-elphel393"


IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE = "131072"
