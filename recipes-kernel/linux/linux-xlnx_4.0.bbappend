FILESEXTRAPATHS_append := "${THISDIR}/linux-xlnx:"
FILESEXTRAPATHS_prepend := "${THISDIR}/config:"

SRC_URI_append += " file://xilinx_nandps_elphel393.patch"
SRC_URI_append += " file://xilinx_emacps.c.patch"
SRC_URI_append += " file://xilinx_uartps.c.patch"
SRC_URI_append += " file://si5338_vsc330x.patch"
SRC_URI_append += " file://drivers-elphel.patch"
SRC_URI_append += " file://drivers-ahci-elphel.patch"

SRC_URI_append += " file://${MACHINE}.scc"
KERNEL_FEATURES_append = " ${MACHINE}.scc"

linux-elphel_label= "git://github.com/Elphel/linux-elphel.git"
linux-elphel_branch= "master"
linux-elphel_gitdir= "${WORKDIR}/linux-elphel"

# To use the latest leave: "" - (=empty)
linux-elphel_srcrev= ""
#linux-elphel_srcrev= "0ca36687a400fd9a5c4510295ae5be88aac77fa4"
#

DEV_DIR ?= "${TOPDIR}/../linux-elphel"
# set output for Eclipse project setup parser:
EXTRA_OEMAKE += "-s -w -j1 -B KCFLAGS='-v'"
# or use a variable:
export _MAKEFLAGS="-s -w -j1 -B KCFLAGS='-v'"
export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE _MAKEFLAGS"
EXTRA_OEMAKE = "${_MAKEFLAGS}"

do_fetch_append() {
    if os.path.isdir("${DEV_DIR}"):
        print("Found DEV_DIR, skipping cloning")
    else:
        print("Cloninig ${linux-elphel_label}\n")
        os.system("git clone -b ${linux-elphel_branch} ${linux-elphel_label} ${linux-elphel_gitdir}")
        os.system("cd ${linux-elphel_gitdir};git checkout ${linux-elphel_srcrev}")
}

python do_link() {
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
                    
        #os.system("cd ${DEV_DIR}; ln -sf ${S} linux")
        if not os.path.isdir("${DEV_DIR}/sysroots"):
                os.system("cd ${DEV_DIR}; ln -sf ${TOPDIR}/tmp/sysroots sysroots")
        if not os.path.isdir("${DEV_DIR}/linux"):
                os.system("cd ${DEV_DIR}; ln -sf ${WORKDIR}/linux-${MACHINE}-standard-build linux")
    else:
        print("Copying ${linux-elphel_gitdir}/src/ over ${S}\n")
        os.system("cp -rfv ${linux-elphel_gitdir}/src/* ${S}")
}

addtask do_link before do_kernel_configme after do_patch

sstate_create_package_append(){
	if [ ! -d ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR} ]; then
		mkdir ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}
	fi
	if [ -f ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_KERNEL} ]; then
		rm ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_KERNEL}
	fi
	if [ -f ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGE_BASE_NAME}.bin ]; then
		cp ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGE_BASE_NAME}.bin ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_KERNEL}
	fi
}
