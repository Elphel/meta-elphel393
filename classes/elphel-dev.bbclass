# developers version

inherit elphel-misc

do_unpack(){
    if [ -d ${S} ]; then
        rm -rf ${S}
        ln -sf ${VPATH} ${S}
    fi
}

do_install_append() {
        oe_runmake 'DESTDIR=${D}' install
}