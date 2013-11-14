FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " file://httpd_port81.conf"

do_install_append() {
    cp ${WORKDIR}/httpd_port81.conf ${D}/${sysconfdir}/${BPN}/httpd.conf
}