SUMMARY = "Userspace application for the Elphel NC393 camera"
DESCRIPTION = "Simple and fast HTTP server to send camera still images"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

VPATH = "${TOPDIR}/../../rootfs-elphel/elphel-apps-imgsrv"

inherit elphel-dev
           
FILES_${PN} += "${bindir}/imgsrv \
                www/pages/exif.php \
                www/pages/start_gps_compass.php \
                www/pages/imu_setup.php \
                ${sysconfdir}/Exif_template.xml \
                "

PACKAGES += "imgsrv"

