SUMMARY = "A recipe for tree prgoram"
DESCRIPTION = "Lists tree"

PRIORITY = "optional"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=393a5ca445f6965873eca0259a17f833"

PR = "r0"

SRC_URI = "http://mama.indstate.edu/users/ice/tree/src/tree-1.6.0.tgz"

SRC_URI[md5sum] = "04e967a3f4108d50cde3b4b0e89e970a"
SRC_URI[sha256sum] = "4dc470a74880338b01da41701d8db90d0fb178877e526d385931a007d68d7591"

S = "${WORKDIR}/tree-1.6.0"

do_compile() {
	# net-tools use COPTS/LOPTS to allow adding custom options
	#export COPTS="$CFLAGS"
	#export LOPTS="$LDFLAGS"
	#unset CFLAGS
	#unset LDFLAGS

	oe_runmake
}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 ${S}/tree ${D}${bindir}
}

PACKAGES = " tree"

INSANE_SKIP_${PN} = "installed-vs-shipped"