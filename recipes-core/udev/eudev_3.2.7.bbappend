
FILESEXTRAPATHS_prepend := "${THISDIR}/eudev:"

SRC_URI += "file://50-udev-default.rules"

do_install_append() {
    # overwrite default rules
    rm ${D}${base_libdir}/udev/rules.d/50-udev-default.rules
    install -m 0644 ${WORKDIR}/50-udev-default.rules ${D}${base_libdir}/udev/rules.d/50-udev-default.rules
}
