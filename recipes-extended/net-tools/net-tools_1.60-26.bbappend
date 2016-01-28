FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append := " file://config.make \
                   file://libmii.c \
                   file://mii-diag.c \
                   file://Makefile"

do_configure() {
	cp ${WORKDIR}/Makefile    ${S}/Makefile
	cp ${WORKDIR}/config.make ${S}/config.make
	cp ${WORKDIR}/libmii.c    ${S}/libmii.c
	cp ${WORKDIR}/mii-diag.c    ${S}/mii-diag.c
	cp ${WORKDIR}/net-tools-config.h    ${S}/config.h
}

base_sbindir_progs_append := " mii-diag"
