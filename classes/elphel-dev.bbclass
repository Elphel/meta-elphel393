# developers version

inherit elphel-misc

do_unpack(){
    if [ -d ${S} ]; then
        rm -rf ${S}
        ln -sf ${VPATH} ${S}
    fi
}

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install_append() {
        oe_runmake 'DESTDIR=${D}' install
}