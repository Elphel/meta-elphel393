SUMMARY = "Simple streamer application"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

VPATH = "${TOPDIR}/../../rootfs-elphel/elphel-apps-astreamer"

inherit elphel-dev

do_configure[noexec] = "1"
#do_compile[noexec] = "1"

DEPENDS += "alsa-lib"

# needed for sysroot?
#DEPENDS += "apache2"

RDEPENDS_apps-astreamer += "alsa-lib"

FILES_${PN} += " ${base_prefix}/usr/bin/*"
