SUMMARY = "A recipe for python extensions to support features of Elphel cameras"
HOMEPAGE = "http://elphel.com"
AUTHOR = "Yuri Nenakhov"
LICENSE = "GPLv2+"
RDEPENDS_${PN} += "\ 
             python-core \
             python-numpy \
             python-ctypes"

LIC_FILES_CHKSUM = "file://LICENSE;md5=891e49b3c2a8c133ffe7985e54245aff"

ELPHELGITHOST ??= "git.elphel.com"

SRC_URI = "git://${ELPHELGITHOST}/Elphel/python-elphel-extensions.git;protocol=https"
#SRCREV = "fbb514aa775b2d07e14403c996810ec1fddb0fa1"
SRCREV = "${AUTOREV}"
SRC_URI[md5sum] = "d54320af9331c798310e083f2e1ffea5"
#SRC_URI[sha256sum] = "b5a0827002a9060e77c55a2e857af4550215c283a3bf94f69f4d7eed22ef1de0"

FILES_${PN} = "${libdir}"

#supress .debug generation
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

S = "${WORKDIR}/git"

do_compile() {
	${CC} -Wall -Wextra -O -ansi -pedantic -shared -fPIC libelphel.c -o libelphel.so 
}

do_install() {
	install -d -m 755 ${D}${libdir}/
	install -d -m 755 ${D}${libdir}/python2.7/
	install -m 755 ${B}/libelphel.so ${D}${libdir}/libelphel.so.0
	install -m 755 ${S}/elphel.py ${D}${libdir}/python2.7/elphel.py
}
