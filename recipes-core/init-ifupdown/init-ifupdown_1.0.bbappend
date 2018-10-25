FILESEXTRAPATHS_prepend_elphel393 := "${THISDIR}/files:"

do_install_append () {
  rm -rf ${D}/etc/network/interfaces
}