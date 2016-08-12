SUMMARY = "Userspace application for the Elphel NC393 camera"
DESCRIPTION = "Simple and fast HTTP server to send camera still images"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

VPATH = "${TOPDIR}/../../rootfs-elphel/elphel-apps-imgsrv"

inherit elphel-dev
           
do_install_append() {
        install -d ${D}${bindir}
        install -m 0755 ${S}/imgsrv ${D}${bindir}
        install -d ${D}/www/pages
        install -m 0755 ${S}/exif.php ${D}/www/pages
        #install -m 0755 ${S}/exif.php ${D}${bindir}
        install -d ${D}${sysconfdir}
        install -m 0644 Exif_template.xml ${D}${sysconfdir}
}

FILES_${PN} += "${bindir}/imgsrv \
                www/pages/exif.php \
                ${sysconfdir}/Exif_template.xml \
                "

PACKAGES += "imgsrv"
