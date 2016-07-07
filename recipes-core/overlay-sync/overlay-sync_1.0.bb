SUMMARY = "Extra scripts for the Elphel 10393 board"
DESCRIPTION = "universal for overlayfs"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"

LICENSE = "GPL-3.0+"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

SRCDATE = "20160706"

PV = "${SRCDATE}"
PR = "r0"

SRC_URI = "file://overlay_sync \
           file://overlay_syncd \
          "

S = "${WORKDIR}/"

INITSCRIPT_NAME = "overlay_syncd"
INITSCRIPT_PARAMS = "start 99 2 3 4 5 . stop 99 0 1 6 ."

FILES_${PN} = "\
           /etc/* \
           /sbin/* \
          "

#This needs to get the script into rc?.d/
inherit update-rc.d

do_install_append() {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/overlay_syncd ${D}${sysconfdir}/init.d
	
	#install init script to /sbin
	install -d ${D}${base_sbindir}
	install -m 0755 ${WORKDIR}/overlay_sync ${D}${base_sbindir}
	
}

PACKAGES = " overlay-sync"
