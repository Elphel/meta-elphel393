# Default Xilinx BSP Machine settings

# File System Configuration
# IMAGE_FSTYPES ?= "cpio tar.gz ext2 ext2.gz.u-boot ext2.gz"
IMAGE_FSTYPES ?= "ext2.gz.u-boot ext2"
#IMAGE_CLASSES += "image_types_uboot"

# Kernel Configuration
PREFERRED_PROVIDER_virtual/kernel ?= "linux-xlnx"
PREFERRED_VERSION_linux-xlnx ?= "4.%"

# U-Boot Configuration
PREFERRED_PROVIDER_virtual/bootloader ?= "u-boot-ezynq"
PREFERRED_PROVIDER_u-boot ?= "u-boot-ezynq"
PREFERRED_VERSION_u-boot-ezynq ?= "v2016.0%"

#PREFERRED_PROVIDER_virtual/bootloader ?= "u-boot-fw-utils"
#PREFERRED_PROVIDER_u-boot ?= "u-boot-fw-utils"

MACHINE_ESSENTIAL_EXTRA_RDEPENDS_append_zynq += "device-tree"