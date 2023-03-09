FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "file://lighttpd.conf \
                  file://test.py \
                  file://phpinfo.php \
                  file://eth0-down-up-test.sh \
                  file://echo.pl \
                  file://wstunnel_count.html \
"

CONFFILES_${PN} = "${D}/lighttpd.conf"

do_install_append() {
    cp ${WORKDIR}/test.py ${D}/www/pages/test.py
    cp ${WORKDIR}/echo.pl ${D}/www/pages/echo.pl
    cp ${WORKDIR}/wstunnel_count.html ${D}/www/pages/wstunnel_count.html
    #cp ${WORKDIR}/phpinfo.php ${D}/www/pages/phpinfo.php
    cp ${WORKDIR}/eth0-down-up-test.sh ${D}/www/pages/eth0-down-up-test.sh
    rm -f ${D}/www/pages/index.html
#    install -m 0644 ${WORKDIR}/lighttpd.conf ${D}${sysconfdir} #installs to /etc/, not needed - already in /etc/lighttpd/
#init_elphel393.py and some others incorrectly used /etc/lighttpd.conf , now all changed to  /etc/lighttpd/lighttpd.conf
}
RDEPENDS_${PN} += " perl"
