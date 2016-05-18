SUMMARY = "Extra initscripts for the Elphel 10393 board"
DESCRIPTION = "Simple camera temperature monitor"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://LICENSE;beginline=21;endline=699;md5=ccd2fef7dee090f3b211c6677c3e34cc"

SRCDATE = "20160516"

PV = "${SRCDATE}"
PR = "r0"

SRC_URI = "file://init_tempmon \
           file://init_tempmon.py \
           file://LICENSE \
          "

S = "${WORKDIR}/"

INITSCRIPT_NAME = "init_tempmon"
INITSCRIPT_PARAMS = "defaults 94"

RDEPENDS_${PN} += "python-core"

FILES_${PN} = "\
           /etc/* \
           /usr/* \
          "
PACKAGES = " init-tempmon"

#This needs to get the script into rc?.d/
inherit update-rc.d

do_install_append() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/init_tempmon ${D}${sysconfdir}/init.d
    install -d ${D}${bindir}
    install -m 0755 ${S}/init_tempmon.py ${D}${bindir}
}
