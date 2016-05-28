SUMMARY = "Extra initscripts for the Elphel 10393 board"
DESCRIPTION = "Add ahci_elphel kernel module to /etc/modprobe.d/blacklist.conf to prevern it from automatic loading during system boot"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

PV = "${SRCDATE}"
PR = "r0"

PACKAGES = "ahci-blacklist"
FILES_${PN} += "${sysconfdir}/modprobe.d/blacklist.conf"

do_install() {
        install -d ${D}${sysconfdir}/modprobe.d
        echo "blacklist ahci_elphel" >> ${D}${sysconfdir}/modprobe.d/blacklist.conf
}

