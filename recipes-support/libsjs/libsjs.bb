SUMMARY = "JS libraries"
SECTION = "libs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRCDATE = "20160419"

PV = "${SRCDATE}"
PR = "r0"

SRC_URI = "https://code.jquery.com/jquery-2.2.3.js;md5sum=aacc43d6f308fa362ac85e3f4fb2b30c \
           https://code.jquery.com/jquery-3.1.1.js;md5sum=46836bbc603c9565b5cc061100ccbac8 \
           http://jqueryui.com/resources/download/jquery-ui-1.12.1.zip;md5sum=e0cfea21c9d1acd37fb58592f2c1f50d \
           https://github.com/twbs/bootstrap/releases/download/v3.3.7/bootstrap-3.3.7-dist.zip;md5sum=3942447fac867ae5cdb3229b658f4d48 \
           http://www.flotcharts.org/downloads/flot-0.8.3.zip;md5sum=a134a869d2b3d476a67a86abbe881676 \
          "
          
#SRC_URI[md5sum] = "33cabfa15c1060aaa3d207c653afb1ee"
#SRC_URI[sha256sum] = "6b6de0d4db7876d1183a3edb47ebd3bbbf93f153f5de1ba6645049348628109a"

PACKAGES = " libsjs"

FILES_${PN} = "www/pages/js/* "

do_install() {
	install -d ${D}/www/pages/js
	install -m 644 ${WORKDIR}/jquery-2.2.3.js ${D}/www/pages/js/
	install -m 644 ${WORKDIR}/jquery-3.1.1.js ${D}/www/pages/js/
	cp -r ${WORKDIR}/jquery-ui-1.12.1 ${D}/www/pages/js/jquery-ui/
	cp -r ${WORKDIR}/bootstrap-3.3.7-dist ${D}/www/pages/js/bootstrap/
	cp -r ${WORKDIR}/flot ${D}/www/pages/js/flot/
}

