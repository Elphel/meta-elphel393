# Adding support for scp files to the target (similar to install) ---

REMOTE_USER ??= "root"
REMOTE_IP ??= "192.168.0.9"
IDENTITY_FILE ??= "~/.ssh/id_rsa"

inherit elphel-ssh

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

    WORKDIR       = d.getVar('WORKDIR'      , True)
    IDENTITY_FILE = d.getVar('IDENTITY_FILE', True)
    REMOTE_USER   = d.getVar('REMOTE_USER'  , True)
    REMOTE_IP     = d.getVar('REMOTE_IP'    , True)
    COPY_TO_NAND  = d.getVar('COPY_TO_NAND' , True)

    # hardcodign for now
    MMC2    = "/dev/mmcblk0p2"
    MMC2MNT = "/mnt/mmc2"

    cmd = "ping "+REMOTE_IP+" -c 1"

    #run_shell_command(cmd)
    ret = subprocess.run("which ls",stderr=subprocess.STDOUT,shell=True)
    print(ret)
    ret = subprocess.run("which scp",stderr=subprocess.STDOUT,shell=True)
    print(ret)
    ret = subprocess.run("which cd",stderr=subprocess.STDOUT,shell=True)
    print(ret)
    ret = subprocess.run("which ping",stderr=subprocess.STDOUT,shell=True)
    print(ret)
    ret = subprocess.run("ls "+WORKDIR,stderr=subprocess.STDOUT,shell=True)
    print(ret)

    print("cmd: "+cmd)
    try:
        ret = subprocess.run(cmd,stderr=subprocess.STDOUT,shell=True)
    except subprocess.CalledProcessError as e:
        print("MOST EPIC FAIL 1: "+str(e.output))
        print("MOST EPIC FAIL 2: "+str(e.cmd))
        raise Exception("No route to target "+REMOTE_IP)

    nandboot = command_over_ssh(d,"'if [ -d /tmp/rootfs.ro ]; then echo 1; else echo 0;fi'")

    if COPY_TO_NAND=='1':

        print("Copy to NAND")

        if nandboot=="1":
            #copy archive
            cmd = "scp -i "+IDENTITY_FILE+" -p "+WORKDIR+"/image.tar.gz "+REMOTE_USER+"@"+REMOTE_IP+":/"
            print("cmd: "+cmd)
            subprocess.run(cmd,stderr=subprocess.STDOUT,shell=True)
            #unpack archive to /
            command_over_ssh(d,"'tar -C / -xzpf /image.tar.gz; sync'")
            #unpack archive to /tmp/rootfs.ro
            command_over_ssh(d,"'tar -C /tmp/rootfs.ro/ -xzpf /image.tar.gz; rm -f /image.tar.gz; sync'")
        else:
            raise Exception("\033[1;37mPlease, reboot from NAND\033[0m")
    else:

        if nandboot=="1":

            print("Copy to MMC while booted from NAND")

            mmc2 = command_over_ssh(d,"'if [ -b "+MMC2+" ]; then echo 1; else echo 0;fi'")
            if mmc2=="1":
                # nobody likes empty output
                mmc2_mnt = command_over_ssh(d,"'TEST=`df -h | grep "+MMC2+"`;echo \"0\"$TEST'")

                if mmc2_mnt!="0":
                  tmp = mmc2_mnt.split()
                  mountpoint = tmp[5]
                  print("MMC rootfs partition is already mounted on "+str(mountpoint))
                else:
                  command_over_ssh(d,"'mkdir "+MMC2MNT+"; mount "+MMC2+" "+MMC2MNT+"'")
                  mountpoint = MMC2MNT
                  print("Created and mounted "+MMC2+" to "+mountpoint)

                #copy archive
                print("Copy archive")
                cmd = "scp -i "+IDENTITY_FILE+" -p "+WORKDIR+"/image.tar.gz "+REMOTE_USER+"@"+REMOTE_IP+":/"
                subprocess.run(cmd,stderr=subprocess.STDOUT,shell=True)

                #unpack archive to mountpoint
                print("Unpack archive then delete")
                command_over_ssh(d,"'EXTRACT_UNSAFE_SYMLINKS=1 tar -C "+mountpoint+" -xzpf /image.tar.gz; rm -f /image.tar.gz; sync'")

            else:
                raise Exception("\033[1;37mMMC rootfs partition "+MMC2+" not found.\033[0m")

        else:

            print("Copy to MMC while booted from MMC")

            #copy archive
            cmd = "scp -i "+IDENTITY_FILE+" -p "+WORKDIR+"/image.tar.gz "+REMOTE_USER+"@"+REMOTE_IP+":/"
            subprocess.run(cmd,stderr=subprocess.STDOUT,shell=True)

            #unpack archive to /
            command_over_ssh(d,"'EXTRACT_UNSAFE_SYMLINKS=1 tar -C / -xzpf /image.tar.gz; rm -f /image.tar.gz; sync'")

}

addtask do_target_scp after do_install

do_target_scp[doc] = "scp installed files to the target. TARGET_USER and TARGET_IP should be defined (ssh-copy-id -i KEY.pub TARGET_USER@TARGET_IP should be issued once)"

EXPORT_FUNCTIONS do_target_scp
#EXPORT_FUNCTIONS command_over_ssh

#REMOTE_USER=root
#REMOTE_IP=192.168.0.7
#DESTDIR=/home/eyesis/git/elphel393/poky/build/tmp/work/cortexa9-neon-poky-linux-gnueabi/web-393/1_0-4/image
#    echo "REMOTE_USER=${REMOTE_USER}"
#    echo "REMOTE_IP=${REMOTE_IP}"
#    echo "DESTDIR=${D}"
#scp -pr image/* root@192.168.0.9:/
