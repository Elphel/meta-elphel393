FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = "file://lighttpd.conf \
                  file://test.py"
CONFFILES_${PN} = "${D}/lighttpd.conf"

do_install_append() {
    cp ${WORKDIR}/test.py ${D}/www/pages/test.py    
}
