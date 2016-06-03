SUMMARY = "Userspace application for the Elphel NC393 camera"
DESCRIPTION = "Simple and fast HTTP server to send camera still images"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

SRCDATE = "20160405"
PV = "${SRCDATE}"
PR = "r0"

DEV_DIR ?= "${TOPDIR}/../../linux-elphel/linux/source"
EXTRA_OEMAKE = "ELPHEL_KERNEL_DIR=${DEV_DIR}"

APPS_DIR = "${TOPDIR}/../../rootfs-elphel"
FILESEXTRAPATHS_append := "${APPS_DIR}/elphel-apps-imgsrv:"

SRC_URI =  "file://imgsrv.c \
            file://Makefile \
            file://exif.php \
            file://Exif_template.xml \
           "
S = "${WORKDIR}"
           
do_install() {
        install -d ${D}${bindir}
        install -m 0755 ${S}/imgsrv ${D}${bindir}
        install -m 0755 ${S}/exif.php ${D}${bindir}
        install -d ${D}${sysconfdir}
        install -m 0644 Exif_template.xml ${D}${sysconfdir}
}

FILES_${PN} += "${bindir}/imgsrv ${bindir}/exif.php ${sysconfdir}/Exif_template.xml"
PACKAGES += "imgsrv"
