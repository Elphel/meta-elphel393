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

#file://overlay_syncd.service
          
S = "${WORKDIR}/"

INITSCRIPT_NAME = "overlay_syncd"
INITSCRIPT_PARAMS = "start 89 2 3 4 5 . stop 89 0 1 6 ."

#SYSTEMD_SERVICE_${PN} = "overlay_syncd.service"

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
	
        # Install systemd related files
	#install -d ${D}${localstatedir}/cache/bind
	#install -d ${D}${sbindir}
	#install -m 0644 ${WORKDIR}/overlay_synced.service ${D}${systemd_unitdir}/system
	#sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
	#       -e 's,@SBINDIR@,${sbindir},g' \
	#       ${D}${systemd_unitdir}/system/overlay_synced.service
}

PACKAGES = " overlay-sync"
