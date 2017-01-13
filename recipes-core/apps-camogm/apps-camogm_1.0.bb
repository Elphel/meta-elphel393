SUMMARY = "Userspace application for the Elphel NC393 camera"
DESCRIPTION = "Simple and fast HTTP server to send camera still images"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

VPATH = "${TOPDIR}/../../rootfs-elphel/elphel-apps-camogm"

inherit elphel-dev

do_configure[noexec] = "1"

DEPENDS += "libogg"

FILES_${PN} += "${bindir}/camogm \
                ${bindir}/camogm_test \
                ${bindir}/format_disk.py \
                ${sysconfdir}/qt_source \
                www/pages/camogmstate.php \
                www/pages/images/create_folder.png \
                www/pages/images/divider.png \
                www/pages/images/filebrowser-01.gif \
                www/pages/images/filebrowser-bottom-01.gif \
                www/pages/images/folder.gif \
                www/pages/images/help.png \
                www/pages/images/play_audio.png \
                www/pages/images/png_white_30.png \
                www/pages/images/quicktime.png \
                www/pages/images/rec_folder.png \
                www/pages/images/record.gif \
                www/pages/images/reload.png \
                www/pages/images/stop.gif \
                www/pages/images/up_folder.gif \
                www/pages/images/hdd.png \
                www/pages/camogm_interface.php \
                www/pages/camogmgui.css \
                www/pages/camogmgui.js \
                www/pages/camogmgui.php \
                www/pages/SpryCollapsiblePanel.css \
                www/pages/SpryCollapsiblePanel.js \
                www/pages/SpryTabbedPanels.css \
                www/pages/SpryTabbedPanels.js \
                www/pages/xml_simple.php \
                "

PACKAGES += " camogm"
