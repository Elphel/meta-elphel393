SUMMARY = "ROS2 scripts for NC393 camera systems"

AUTHOR = "Elphel Inc."
HOMEPAGE = "https://www.elphel.com"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

VPATH = "${TOPDIR}/../../rootfs-elphel/ros2-scripts"

inherit elphel-dev

do_configure[noexec] = "1"
#do_compile[noexec] = "1"

FILES_${PN} += " ${base_prefix}/etc/elphel393/*"
