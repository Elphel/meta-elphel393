SUMMARY = "Extra initscripts for the Elphel 10393 board"
DESCRIPTION = "Simple camera temperature monitor"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"
LICENSE = "GPL-3.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

SRCDATE = "20160516"

PV = "${SRCDATE}"
PR = "r0"

SRC_URI = "file://init_tempmon \
           file://init_tempmon.py \
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
