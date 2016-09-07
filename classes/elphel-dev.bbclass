# developers version

inherit elphel-misc

do_unpack(){
    if [ -d ${S} ]; then
        rm -rf ${S}
    fi
    ln -sf ${VPATH} ${S}
}

EXTRA_OEMAKE = " \
                DESTDIR=${D} \
                ELPHEL_KERNEL_DIR=${STAGING_KERNEL_DIR} \
                STAGING_KERNEL_DIR=${STAGING_KERNEL_DIR} \
                STAGING_DIR_HOST=${STAGING_DIR_HOST} \
                REMOTE_USER=${REMOTE_USER} \
                REMOTE_IP=${REMOTE_IP} \
                "

do_install_append() {
        oe_runmake ${EXTRA_OEMAKE} install
}

# --- Adding support for scp installed files to the target  ---
do_target_scp () {
#Without next echo - no trace of the scp in the log!
    SSH_COMMAND='tar -C / -xzpf /image.tar.gz; rm -f /image.tar.gz; sync'
    tar -czvf ${WORKDIR}/image.tar.gz -C ${WORKDIR}/image .
    echo scp -p ${WORKDIR}/image.tar.gz ${REMOTE_USER}@${REMOTE_IP}:/
    scp -p ${WORKDIR}/image.tar.gz ${REMOTE_USER}@${REMOTE_IP}:/
    echo ssh ${REMOTE_USER}@${REMOTE_IP} ${SSH_COMMAND}
    ssh ${REMOTE_USER}@${REMOTE_IP} ${SSH_COMMAND}
}
addtask do_target_scp after do_install
do_target_scp[doc] = "scp installed files to the target. TARGET_USER and TARGET_IP should be defined (ssh-copy-id TARGET_USER@TARGET_USER should be issued once)"
EXPORT_FUNCTIONS do_target_scp
