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
}

EXTRA_OEMAKE = " \
                DESTDIR=${D} \
                ELPHEL_KERNEL_DIR=${STAGING_KERNEL_DIR} \
                STAGING_KERNEL_DIR=${STAGING_KERNEL_DIR} \
                STAGING_DIR_HOST=${STAGING_DIR_HOST} \
                "

do_install_append() {
        oe_runmake ${EXTRA_OEMAKE} install
}