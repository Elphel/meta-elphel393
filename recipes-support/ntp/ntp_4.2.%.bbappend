FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

libexecdir = "/usr/lib/ntp"

EXTRA_OECONF += "--libexecdir=/usr/lib/ntp \
		"