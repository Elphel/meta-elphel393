# Adding support for scp files to the target (similar to install) ---

do_target_scp () {
    SOURCE_PATH="${D}/*"
#    echo "scp -pr ${SOURCE_PATH} ${REMOTE_USER}@${REMOTE_IP}:/"
    scp -pr ${SOURCE_PATH} ${REMOTE_USER}@${REMOTE_IP}:/
}

addtask do_target_scp after do_install

do_target_scp[doc] = "scp installed files to the target. TARGET_USER and TARGET_IP should be defined (ssh-copy-id TARGET_USER@TARGET_USER should be issued once)"

EXPORT_FUNCTIONS do_target_scp

#REMOTE_USER=root
#REMOTE_IP=192.168.0.7
#DESTDIR=/home/eyesis/git/elphel393/poky/build/tmp/work/cortexa9-neon-poky-linux-gnueabi/web-393/1_0-4/image
#    echo "REMOTE_USER=${REMOTE_USER}"
#    echo "REMOTE_IP=${REMOTE_IP}"
#    echo "DESTDIR=${D}"
#scp -pr image/* root@192.168.0.7:/    
