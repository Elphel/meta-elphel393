LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "git://github.com/inertialsense/inertial-sense-sdk.git;protocol=https"
SRCREV = "0757da6f2e0fb3c430f6e6f5af0d5f3411fdb1b1"

DEPENDS = "libusb1"
inherit cmake

S = "${WORKDIR}/git"

do_install () {
	install -D -m 0755 ${WORKDIR}/build/cltool/cltool ${D}${bindir}/cltool
}

