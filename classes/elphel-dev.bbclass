# developers version

inherit elphel-misc

do_unpack(){
    if [ -d ${S} ]; then
        rm -rf ${S}
    fi
    ln -sf ${VPATH} ${S}
    
    if [ -d ${VPATH}/sysroots ]; then
        rm -rf ${VPATH}/sysroots
    fi
    ln -sf ${TOPDIR}/tmp/sysroots ${VPATH}/sysroots
    
    if [ -d ${VPATH}/bitbake-logs ]; then
        rm -rf ${VPATH}/bitbake-logs
    fi
    ln -sf ${WORKDIR}/temp ${VPATH}/bitbake-logs
}

EXTRA_OEMAKE = " \
                DESTDIR=${D} \
                ELPHEL_KERNEL_DIR=${STAGING_KERNEL_DIR} \
                STAGING_KERNEL_DIR=${STAGING_KERNEL_DIR} \
                STAGING_DIR_HOST=${STAGING_DIR_HOST} \
                "

do_compile_prepend() {
    if [ ! -f Makefile ]; then
        echo "Nothing to compile (missing a Makefile)"
        exit 1
    fi
}
                
do_install_append() {
        oe_runmake ${EXTRA_OEMAKE} install
}
