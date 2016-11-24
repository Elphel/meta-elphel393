# Well

inherit elphel-misc-functions

VFILE = "VERSION"
PE = "${@version_update('${VPATH}','${VFILE}',0)}"
PV = "${@version_update('${VPATH}','${VFILE}',1)}"
PR = "${@version_update('${VPATH}','${VFILE}',2)}"

#SRCREV = "${PE}.${PV}.${PR}"
#SRCPV = "${PE}.${PV}.${PR}"
#SRCPV = "${AUTOREV}"
#__BB_DONT_CACHE = "1"

SRCREV = "${AUTOREV}"

FILESEXTRAPATHS_append := "${VPATH}:"
