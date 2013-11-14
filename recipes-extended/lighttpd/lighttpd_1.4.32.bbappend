FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = "file://lighttpd.conf"
CONFFILES_${PN} = "${D}/lighttpd.conf"
