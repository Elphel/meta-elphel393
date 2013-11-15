inherit kernel

# This version extension should match CONFIG_LOCALVERSION in defconfig
LINUX_VERSION_EXTENSION ?= "-xilinx"

require recipes-kernel/linux/linux-yocto.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/linux-xlnx:"
SRC_URI = "git://github.com/Xilinx/linux-xlnx;protocol=git;nocheckout=1"

PR = "r1"
PV = "${LINUX_VERSION}${LINUX_VERSION_EXTENSION}+git${SRCPV}"

SRC_URI_append += "file://xilinx_nandps.patch"

# MACHINE=elphel393
SRC_URI_append_elphel393 += "file://elphel393_defconfig_${LINUX_VERSION}.cfg \
                             file://dts/elphel393.dts"
                             
KERNEL_DEVICETREE_elphel393 = "${WORKDIR}/dts/elphel393.dts"

#MACHINE=microzed
#Copy of zedboard's defconfig
SRC_URI_append_microzed += "file://microzed_defconfig_${LINUX_VERSION}.cfg \
                            file://dts/microzed.dts"

KERNEL_DEVICETREE_microzed = "${WORKDIR}/dts/microzed.dts"

#MACHINE=zedboard
#Copy of zedboard's defconfig
SRC_URI_append_zedboard += "file://microzed_defconfig_${LINUX_VERSION}.cfg \
                            file://dts/zynq-zed.dts"

KERNEL_DEVICETREE_zedboard = "${WORKDIR}/dts/zynq-zed.dts"

#MACHINE=zc706
#Copy of zedboard's defconfig
SRC_URI_append_zc706 += "file://microzed_defconfig_${LINUX_VERSION}.cfg \
                            file://dts/zynq-zc706.dts"
KERNEL_DEVICETREE_zc706 = "${WORKDIR}/dts/zynq-zc706.dts"