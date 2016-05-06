SUMMARY = "Userspace application for the Elphel NC393 camera"
DESCRIPTION = "Simple and fast HTTP server to send camera still images"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://LICENSE;beginline=21;endline=699;md5=ccd2fef7dee090f3b211c6677c3e34cc"

SRCDATE = "20160503"

PV = "${SRCDATE}"
PR = "r0"

DEV_DIR ?= "${TOPDIR}/../../linux-elphel/linux/source"
EXTRA_OEMAKE = "ELPHEL_KERNEL_DIR=${DEV_DIR}"

APPS_DIR = "${TOPDIR}/../../rootfs-elphel"
FILESEXTRAPATHS_append := "${APPS_DIR}/elphel-apps-camogm:"

S = "${WORKDIR}"

SRC_URI =  "file://.* \
            file://LICENSE \
           "

do_install() {
        install -d ${D}${bindir}
        install -m 0755 ${S}/camogm ${D}${bindir}
}

PACKAGES = " camogm"
