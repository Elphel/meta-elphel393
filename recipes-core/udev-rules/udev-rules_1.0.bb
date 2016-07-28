SUMMARY = "Extra initscripts for the Elphel 10393 board"
DESCRIPTION = "udev rules for automounting disk drives to /mnt or /media directories"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

SRCDATE = "20160530"
PV = "${SRCDATE}"
PR = "r0"
S = "${WORKDIR}"

SRC_URI = "file://90-elphel-automount.rules \
		  "
RDEPENDS_${PN} = "udev"

PACKAGES = "udev-rules"
UDEV_RULES_DIR = "${sysconfdir}/udev/rules.d"
FILES_${PN} += "${UDEV_RULES_DIR}/90-elphel-automount.rules"

do_install() {
        install -d ${D}${UDEV_RULES_DIR}
        install -m 644 ${WORKDIR}/90-elphel-automount.rules ${D}${UDEV_RULES_DIR}
}

