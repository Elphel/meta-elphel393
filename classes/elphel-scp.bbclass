# Adding support for scp files to the target (similar to install) ---

IDENTITY_FILE ??= "~/.ssh/id_rsa"

do_target_scp () {
    #Without next echo - no trace of the scp in the log!
    tar -czvf ${WORKDIR}/image.tar.gz -C ${WORKDIR}/image .
    echo scp -i ${IDENTITY_FILE} -p ${WORKDIR}/image.tar.gz ${REMOTE_USER}@${REMOTE_IP}:/
    scp -i ${IDENTITY_FILE} -p ${WORKDIR}/image.tar.gz ${REMOTE_USER}@${REMOTE_IP}:/
    echo ssh -i ${IDENTITY_FILE} ${REMOTE_USER}@${REMOTE_IP} ${SSH_COMMAND}
    ssh -i ${IDENTITY_FILE} ${REMOTE_USER}@${REMOTE_IP} ${SSH_COMMAND}
}

addtask do_target_scp after do_install

do_target_scp[doc] = "scp installed files to the target. TARGET_USER and TARGET_IP should be defined (ssh-copy-id -i KEY.pub TARGET_USER@TARGET_IP should be issued once)"

EXPORT_FUNCTIONS do_target_scp

#REMOTE_USER=root
#REMOTE_IP=192.168.0.7
#DESTDIR=/home/eyesis/git/elphel393/poky/build/tmp/work/cortexa9-neon-poky-linux-gnueabi/web-393/1_0-4/image
#    echo "REMOTE_USER=${REMOTE_USER}"
#    echo "REMOTE_IP=${REMOTE_IP}"
#    echo "DESTDIR=${D}"
#scp -pr image/* root@192.168.0.9:/  
