SUMMARY = "Extra initscripts for the Elphel 10393 board"
DESCRIPTION = "Platform/board specific initializations"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"
#LICENSE = "GPLv3"
#LIC_FILES_CHKSUM = "file://LICENSE;beginline=21;endline=699;md5=ccd2fef7dee090f3b211c6677c3e34cc"

LICENSE = "GPL-3.0+"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

SRCDATE = "20131202"

#PV = "${SRCDATE}"
#PR = "r0"

# PV,PR update
inherit elphel-misc
VPATH = "${TOPDIR}/../../fpga-elphel/x393"

RDEPENDS_${PN} += "\
             python-core \
             "

SRC_URI = "file://init_elphel393 \
           file://init_elphel393.sh \
           file://LICENSE \
          "

S = "${WORKDIR}/"

INITSCRIPT_NAME = "init_elphel393"
INITSCRIPT_PARAMS = "defaults 95"

FILES_${PN} = "\
           /etc/* \
           /usr/* \
           /www/pages/* \
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

	#install init script to /etc
	install -m 0755 ${WORKDIR}/init_elphel393.sh ${D}${sysconfdir}/

    for RLOC in ${PRODUCTION_ROOT_LOCATION}; do
        if [ ! -d ${DEPLOY_DIR_IMAGE}/${RLOC} ]; then
            mkdir -p ${DEPLOY_DIR_IMAGE}/${RLOC}
        fi
        #if [ -f ${S}init_elphel393.sh ]; then
        #    if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/init_elphel393.sh ]; then
        #        rm ${DEPLOY_DIR_IMAGE}/${RLOC}/init_elphel393.sh
        #    fi
        #    cp ${S}init_elphel393.sh ${DEPLOY_DIR_IMAGE}/${RLOC}/init_elphel393.sh
        #else
        #    echo "NOT 3 FOUND!"
        #fi
    done
}

PACKAGES = " init-elphel393"
