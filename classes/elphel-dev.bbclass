# developers version

inherit elphel-misc elphel-scp

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
    
    if [ -d ${VPATH}/image ]; then
        rm -rf ${VPATH}/image
    fi
    ln -sf ${WORKDIR}/image ${VPATH}/image
}

ELPHEL393_USERADD = "eval ${FAKEROOTENV} PSEUDO_LOCALSTATEDIR=${STAGING_DIR_TARGET}${localstatedir}/pseudo ${STAGING_DIR_NATIVE}${bindir}/pseudo useradd --root ${STAGING_DIR_HOST}"
ELPHEL393_INSTALL = "install"
ELPHEL393_MKNOD = "mknod"

INITSTRING ??= "somescript.sh"

EXTRA_OEMAKE = " \
                INSTALL=${ELPHEL393_INSTALL} \
                MKNOD=${ELPHEL393_MKNOD} \
                DESTDIR=${D} \
                ELPHEL_KERNEL_DIR=${STAGING_KERNEL_DIR} \
                STAGING_KERNEL_DIR=${STAGING_KERNEL_DIR} \
                STAGING_DIR_HOST=${STAGING_DIR_HOST} \
                USERADD='${ELPHEL393_USERADD}' \
                REMOTE_USER=${REMOTE_USER} \
                REMOTE_IP=${REMOTE_IP} \
                SRCREV=${SRCREV} \
                VERSION='${PE}.${PV}.${PR}' \
                INITSTRING='${INITSTRING}' \
                "

do_compile_prepend() {
    echo "SRCREV is ${SRCREV}"
    if [ ! -f Makefile ]; then
        echo "Nothing to compile (missing a Makefile)"
        exit 1
    fi
}
                
do_install_append() {
        oe_runmake ${EXTRA_OEMAKE} install
        install -d ${D}/etc/elphel393/packages
        echo "${PE}.${PV}.${PR}" > ${D}/etc/elphel393/packages/${BPN}
}

# Always start from compile
# link1: http://www.crashcourse.ca/wiki/index.php/BitBake_task_flags
do_compile[nostamp]="1"
