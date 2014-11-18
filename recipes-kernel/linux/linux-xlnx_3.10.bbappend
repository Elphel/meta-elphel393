FILESEXTRAPATHS_append := "${THISDIR}/linux-xlnx:"

SRC_URI_append += " file://xilinx_nandps_elphel393.patch"
SRC_URI_append += " file://xilinx_emacps.c.patch"
SRC_URI_append += " file://si5338_vsc330x.patch"
SRC_URI_append += " file://drivers-elphel.patch"

# Kernel version and SRCREV correspond to:
# github.com/Xilinx/linux-xlnx.git xilinx-v14.7 tag
SRCREV = "efc27505715e64526653f35274717c0fc56491e3"

linux-elphel_label= "git://git.code.sf.net/p/elphel/linux-elphel"
linux-elphel_branch= "master"
linux-elphel_gitdir= "${WORKDIR}/linux-elphel"
# To use the latest leave: "" - (=empty)
linux-elphel_srcrev= ""
#linux-elphel_srcrev= "0ca36687a400fd9a5c4510295ae5be88aac77fa4"

DEV_DIR ?= "${TOPDIR}/../linux-elphel"

do_fetch_append() {
    if os.path.isdir("${DEV_DIR}"):
        print("Found DEV_DIR, skipping cloning")
    else:
        print("Cloninig ${linux-elphel_label}\n")
        os.system("git clone -b ${linux-elphel_branch} ${linux-elphel_label} ${linux-elphel_gitdir}")
        os.system("cd ${linux-elphel_gitdir};git checkout ${linux-elphel_srcrev}")
}

do_unpack_append() {
    if os.path.isdir("${DEV_DIR}"):
        print("DEV_DIR exists - creating links...")
        devdir_abspath = os.path.abspath("${DEV_DIR}/src")
        for path, folders, files in os.walk("${DEV_DIR}/src"):
            folders[:]=[fd for fd in folders if fd != ".git"]
            for folder in folders:
                folder_abspath = os.path.abspath(os.path.join(path, folder))
                folder_relpath = folder_abspath.replace(devdir_abspath+"/", '')
                os.system("cd ${S};mkdir -p "+folder_relpath)
            for filename in files:
                file_abspath = os.path.abspath(os.path.join(path, filename))
                file_relpath = file_abspath.replace(devdir_abspath+"/", '')
                os.system("cd ${S};ln -s "+file_abspath+" "+file_relpath)
        os.system("cd ${DEV_DIR}; ln -sf ${S} linux") 
        os.system("cd ${DEV_DIR}; ln -sf ${TOPDIR}/tmp/sysroots sysroots") 
    else:
        print("Copying ${linux-elphel_gitdir}/src/ over ${S}\n")
        os.system("cp -rfv ${linux-elphel_gitdir}/src/* ${S}")
}