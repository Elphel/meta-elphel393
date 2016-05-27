SUMMARY = "Temporary WebGUI pages"
DESCRIPTION = "Temporary WebGUI pages"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"
LICENSE = "AGPL-3.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/AGPL-3.0;md5=73f1eb20517c55bf9493b7dd6e480788"

SRCDATE = "20160518"
PV = "${SRCDATE}"
PR = "r0"

SRC_URI = "file://controls.html \
           file://controls.js \
           file://hwmon.html \
           file://hwmon.js \
           file://hwmon.php \
           file://setup.css \
           file://setup.html \
           file://setup.js \
           file://setup.php \
           file://index.html \
          "

S = "${WORKDIR}/"

FILES_${PN} = "\
           www/pages/* \
          "

do_install_append() {
    install -d ${D}/www/pages
    install -m 0644 ${WORKDIR}/controls.html ${D}/www/pages
    install -m 0644 ${WORKDIR}/controls.js ${D}/www/pages
    install -m 0644 ${WORKDIR}/hwmon.html ${D}/www/pages
    install -m 0644 ${WORKDIR}/hwmon.js ${D}/www/pages
    install -m 0644 ${WORKDIR}/hwmon.php ${D}/www/pages
    install -m 0644 ${WORKDIR}/setup.css ${D}/www/pages
    install -m 0644 ${WORKDIR}/setup.html ${D}/www/pages
    install -m 0644 ${WORKDIR}/setup.js ${D}/www/pages
    install -m 0644 ${WORKDIR}/setup.php ${D}/www/pages
    install -m 0644 ${WORKDIR}/index.html ${D}/www/pages
}

PACKAGES = " apps-web"

#supress .debug generation
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"
          