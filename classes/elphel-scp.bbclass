# Adding support for scp files to the target (similar to install) ---

REMOTE_USER ??= "root"
REMOTE_IP ??= "192.168.0.9"
IDENTITY_FILE ??= "~/.ssh/id_rsa"

#do_target_scp () {
#    #Without next echo - no trace of the scp in the log!
#    SSH_COMMAND='tar -C / -xzpf /image.tar.gz; rm -f /image.tar.gz; sync'
#    tar -czvf ${WORKDIR}/image.tar.gz -C ${WORKDIR}/image .
#    echo scp -i ${IDENTITY_FILE} -p ${WORKDIR}/image.tar.gz ${REMOTE_USER}@${REMOTE_IP}:/
#    scp -i ${IDENTITY_FILE} -p ${WORKDIR}/image.tar.gz ${REMOTE_USER}@${REMOTE_IP}:/
#    echo ssh -i ${IDENTITY_FILE} ${REMOTE_USER}@${REMOTE_IP} ${SSH_COMMAND}
#    ssh -i ${IDENTITY_FILE} ${REMOTE_USER}@${REMOTE_IP} ${SSH_COMMAND}
#}

python do_target_scp () {
    import subprocess

    WORKDIR = d.getVar('WORKDIR', True)
    IDENTITY_FILE = d.getVar('IDENTITY_FILE', True)
    REMOTE_USER = d.getVar('REMOTE_USER', True)
    REMOTE_IP = d.getVar('REMOTE_IP', True)

    cmd = "tar -czvf "+WORKDIR+"/image.tar.gz -C "+WORKDIR+"/image ."
    subprocess.check_output(cmd,stderr=subprocess.STDOUT,shell=True)

    cmd = "ping "+REMOTE_IP+" -c 1"
    try:
        subprocess.check_output(cmd,stderr=subprocess.STDOUT,shell=True)
    except subprocess.CalledProcessError:
        raise Exception("No route to target "+REMOTE_IP)

    cmd = "scp -i "+IDENTITY_FILE+" -p "+WORKDIR+"/image.tar.gz "+REMOTE_USER+"@"+REMOTE_IP+":/"
    try:
        subprocess.check_output(cmd,stderr=subprocess.STDOUT,shell=True)
    except subprocess.CalledProcessError:
        raise Exception("Copying to target requires access by public key. Run: ssh-copy-id "+REMOTE_USER+"@"+REMOTE_IP)

    cmd = "ssh -i "+IDENTITY_FILE+" "+REMOTE_USER+"@"+REMOTE_IP+" tar -C / -xzpf /image.tar.gz; rm -f /image.tar.gz; sync"
    subprocess.check_output(cmd,stderr=subprocess.STDOUT,shell=True)
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
