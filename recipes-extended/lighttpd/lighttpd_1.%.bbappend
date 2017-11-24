FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

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
    rm -f ${D}/www/pages/index.html
}
