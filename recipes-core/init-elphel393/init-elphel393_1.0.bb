SUMMARY = "Extra initscripts for the Elphel 10393 board"
DESCRIPTION = "Platform/board specific initializations"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://LICENSE;beginline=21;endline=699;md5=ccd2fef7dee090f3b211c6677c3e34cc"

SRCDATE = "20131202"

PV = "${SRCDATE}"
PR = "r0"

SRC_URI = "file://init_elphel393 \
           file://LICENSE \
          "

S = "${WORKDIR}/"

INITSCRIPT_NAME = "init_elphel393"
INITSCRIPT_PARAMS = "defaults 95"

FILES_${PN} = "\
           /etc/* \
           /usr/* \
          "

#This needs to get the script into rc?.d/
inherit update-rc.d

do_install_append() {
	if [ -f ${TOPDIR}/../../fpga-elphel/x393/install.sh ]; then
		${TOPDIR}/../../fpga-elphel/x393/install.sh ${D}
	fi
	if [ -f ${TOPDIR}/../../fpga-elphel/x393_sata/install.sh ]; then
		${TOPDIR}/../../fpga-elphel/x393_sata/install.sh ${D}
	fi
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/init_elphel393 ${D}${sysconfdir}/init.d
}

PACKAGES = " init-elphel393"
