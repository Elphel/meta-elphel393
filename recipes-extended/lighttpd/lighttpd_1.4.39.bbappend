FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "http://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-${PV}.tar.xz \
        file://index.html.lighttpd \
        file://lighttpd.conf \
        file://lighttpd \
        file://lighttpd.service \
        file://pkgconfig.patch \
        "

SRC_URI_append = "file://lighttpd.conf \
                  file://test.py \
                  file://phpinfo.php \
                  file://eth0-down-up-test.sh \
"

CONFFILES_${PN} = "${D}/lighttpd.conf"

do_install_append() {
    cp ${WORKDIR}/test.py ${D}/www/pages/test.py    
    cp ${WORKDIR}/phpinfo.php ${D}/www/pages/phpinfo.php
    cp ${WORKDIR}/eth0-down-up-test.sh ${D}/www/pages/eth0-down-up-test.sh
}
