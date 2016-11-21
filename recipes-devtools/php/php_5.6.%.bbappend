
EXTRA_OECONF += "--enable-elphel \
                --with-curl=${STAGING_LIBDIR}/.. \
                --with-readline=${STAGING_LIBDIR}/.. \
                "


VPATH = "${TOPDIR}/../../rootfs-elphel/elphel-apps-php-extension"

do_unpack_append(){
    print("Link everything to the main tree")
    VPATH = d.getVar('VPATH', True)
    S = d.getVar('S', True)
    TOPDIR = d.getVar('TOPDIR', True)
    WORKDIR = d.getVar('WORKDIR', True)
    
    if os.path.isdir(VPATH):
        print("VPATH exists - creating links...")        
        devdir_abspath = os.path.abspath(VPATH+"/src")
        for path, folders, files in os.walk(VPATH+"/src"):
            folders[:]=[fd for fd in folders if fd != ".git"]
            for folder in folders:
                folder_abspath = os.path.abspath(os.path.join(path, folder))
                folder_relpath = folder_abspath.replace(devdir_abspath+"/", '')
                os.system("cd "+S+";mkdir -p "+folder_relpath)
            for filename in files:
                file_abspath = os.path.abspath(os.path.join(path, filename))
                file_relpath = file_abspath.replace(devdir_abspath+"/", '')
                os.system("cd "+S+";ln -sf "+file_abspath+" "+file_relpath)
        #make a link back:
        
        if os.path.isdir(VPATH+"/php"):
            os.system("rm -rf "+VPATH+"/php")
        os.system("ln -sf "+S+" "+VPATH+"/php")
            
        if os.path.isdir(VPATH+"/sysroots"):
            os.system("rm -rf "+VPATH+"/sysroots")
        os.system("ln -sf "+TOPDIR+"/tmp/sysroots "+VPATH+"/sysroots")
        
        if os.path.isdir(VPATH+"/bitbake-logs"):
            os.system("rm -rf "+VPATH+"/bitbake-logs")
        os.system("ln -sf "+WORKDIR+"/temp "+VPATH+"/bitbake-logs")

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
