SUMMARY = "WWW content for basic NC393 camera"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

VPATH = "${TOPDIR}/../../rootfs-elphel/elphel-web-393"

inherit elphel-dev

do_configure[noexec] = "1"
#do_compile[noexec] = "1"

FILES_${PN} += " ${base_prefix}/www/pages/* ${base_prefix}/usr/local/bin/*"

