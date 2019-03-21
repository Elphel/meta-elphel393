
FILESEXTRAPATHS_prepend := "${THISDIR}/mtd-utils:"

PV = "2.0.0"

SRCREV = "1bfee8660131fca7a18f68e9548a18ca6b3378a0"

SRC_URI = "git://git.infradead.org/mtd-utils.git \
           file://add-exclusion-to-mkfs-jffs2-git-2.patch \
           file://fix-armv7-neon-alignment.patch \
           file://mtd-utils-fix-corrupt-cleanmarker-with-flash_erase--j-command.patch \
           file://0001-Fix-build-with-musl.patch \
           file://010-fix-rpmatch.patch \
"
