# developers version

DEPENDS += "linux-xlnx"

inherit elphel-misc elphel-scp

do_unpack(){
    if [ -d ${S} ]; then
        rm -rf ${S}
    fi
    ln -sf ${VPATH} ${S}

    if [ -d ${VPATH}/sysroots ]; then
        rm -rf ${VPATH}/sysroots
    fi
    # old:
    #ln -sf ${TOPDIR}/tmp/sysroots ${VPATH}/sysroots
    # new:
    ln -sf ${WORKDIR}/recipe-sysroot ${VPATH}/sysroots

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

REMOTE_NETMASK ??= "255.255.255.0"
REMOTE_GATEWAY ??= "192.168.0.15"

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
                REMOTE_NETMASK=${REMOTE_NETMASK} \
                REMOTE_GATEWAY=${REMOTE_GATEWAY} \
                SRCREV=${SRCREV} \
                VERSION='${PE}.${PV}.${PR}' \
                INITSTRING='${INITSTRING}' \
                "

do_clean_append() {

    import os.path

    VPATH = d.getVar("VPATH")
    dfile = os.path.join(VPATH,"src/.depend")

    if os.path.exists(dfile):
        os.remove(dfile)

}

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
        TMPNAME=`basename ${VPATH}`
        echo "${PE}.${PV}.${PR}" > ${D}/etc/elphel393/packages/${BPN}
        #make archive
        tar -czvf ${WORKDIR}/image.tar.gz -C ${WORKDIR}/image .
}

# Always start from compile
# link1: http://www.crashcourse.ca/wiki/index.php/BitBake_task_flags
#do_compile[nostamp]="1"
