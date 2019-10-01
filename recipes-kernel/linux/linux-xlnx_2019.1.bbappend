FILESEXTRAPATHS_append := "${TOPDIR}/../../linux-elphel/src/patches:"
FILESEXTRAPATHS_prepend := "${THISDIR}/config:"

SRC_URI_append += " file://garmin_usb.c.patch"
SRC_URI_append += " file://drivers-elphel.patch"
SRC_URI_append += " file://ahci.patch"
SRC_URI_append += " file://libahci.patch"
SRC_URI_append += " file://libata-eh.c.patch"
SRC_URI_append += " file://rtc-m41t80.c.patch"
SRC_URI_append += " file://sdhci.c.patch"
SRC_URI_append += " file://macb_main.c.patch"

#SRC_URI_append += " file://xilinx_emacps.c.patch"
#SRC_URI_append += " file://xilinx_uartps.c.patch"
#SRC_URI_append += " file://si5338_vsc330x.patch"

SRC_URI_append += " file://${MACHINE}.scc"
KERNEL_FEATURES_append = " ${MACHINE}.scc"

ELPHELGITHOST ??= "git.elphel.com"

linux-elphel_label= "https://${ELPHELGITHOST}/Elphel/linux-elphel.git"
linux-elphel_branch= "master"
linux-elphel_gitdir= "${WORKDIR}/linux-elphel"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

# linux xilinx hash for xlnx_rebase_v4.19
SRCREV = "9811303824b66a8db9a8ec61b570879336a9fde5"

# To use the latest leave: "" - (=empty)
linux-elphel_srcrev= ""
#linux-elphel_srcrev= "0ca36687a400fd9a5c4510295ae5be88aac77fa4"
#

DEV_DIR ?= "${TOPDIR}/../../linux-elphel"

# set output for Eclipse project setup parser:
EXTRA_OEMAKE += "-s -w -B KCFLAGS='-v'"
# or use a variable:
export _MAKEFLAGS="-s -w -B KCFLAGS='-v'"
export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE _MAKEFLAGS"
EXTRA_OEMAKE = "${_MAKEFLAGS}"

INITRAMFS_IMAGE = "core-image-elphel393-initramfs"
INITRAMFS_IMAGE_BUNDLE = "1"
#IMAGE_FSTYPES = "cpio.gz"

do_fetch_append() {
    DEV_DIR = d.getVar('DEV_DIR', True)
    linux_elphel_label  = d.getVar('linux-elphel_label', True)
    linux_elphel_branch = d.getVar('linux-elphel_branch', True)
    linux_elphel_gitdir = d.getVar('linux-elphel_gitdir', True)
    linux_elphel_srcrev = d.getVar('linux-elphel_srcrev', True)

    if os.path.isdir(DEV_DIR):
        print("Found DEV_DIR, skipping cloning")
    else:
        print("Cloninig "+linux-elphel_label+"\n")
        os.system("git clone -b "+linux_elphel_branch+" "+linux_elphel_label+" "+linux_elphel_gitdir)
        os.system("cd "+linux_elphel_gitdir+";git checkout "+linux_elphel_srcrev)
}

python do_link() {
    DEV_DIR = d.getVar('DEV_DIR', True)
    S = d.getVar('S', True)
    TOPDIR = d.getVar('TOPDIR', True)
    WORKDIR = d.getVar('WORKDIR', True)
    MACHINE = d.getVar('MACHINE', True)
    linux_elphel_gitdir = d.getVar('linux-elphel_gitdir', True)

    if os.path.isdir(DEV_DIR):
        print("DEV_DIR exists - creating links...")
        devdir_abspath = os.path.abspath(DEV_DIR+"/src")
        for path, folders, files in os.walk(DEV_DIR+"/src"):
            folders[:]=[fd for fd in folders if fd != ".git"]
            for folder in folders:
                folder_abspath = os.path.abspath(os.path.join(path, folder))
                folder_relpath = folder_abspath.replace(devdir_abspath+"/", '')
                os.system("cd "+S+";mkdir -p "+folder_relpath)
            for filename in files:
                file_abspath = os.path.abspath(os.path.join(path, filename))
                file_relpath = file_abspath.replace(devdir_abspath+"/", '')
                os.system("cd "+S+";ln -sf "+file_abspath+" "+file_relpath)

        #os.system("cd "+DEV_DIR+"; ln -sf "+S+" linux")
        if not os.path.isdir(DEV_DIR+"/sysroots"):
                os.system("cd "+DEV_DIR+"; ln -sf "+WORKDIR+"/recipe-sysroot sysroots")
        if not os.path.isdir(DEV_DIR+"/linux"):
                os.system("cd "+DEV_DIR+"; ln -sf "+WORKDIR+"/linux-"+MACHINE+"-standard-build linux")
        if not os.path.isdir(DEV_DIR+"/image"):
                os.system("cd "+DEV_DIR+"; ln -sf "+WORKDIR+"/image image")
    else:
        print("Copying "+linux_elphel_gitdir+"/src/ over "+S+"\n")
        os.system("cp -rfv "+linux_elphel_gitdir+"/src/* "+S)
}

addtask do_link before do_kernel_configme after do_patch

do_deploy_append(){
    for RLOC in ${PRODUCTION_ROOT_LOCATION}; do
        if [ ! -d ${DEPLOY_DIR_IMAGE}/${RLOC} ]; then
            mkdir -p ${DEPLOY_DIR_IMAGE}/${RLOC}
        fi
        #if [ -f ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGE_BASE_NAME}.bin ]; then

        # ROCKO: "uImage-" had to be added?!

        if [ -f ${DEPLOYDIR}/uImage-${KERNEL_IMAGE_NAME}.bin ]; then
            if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL} ]; then
                rm ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
            fi
            cp ${DEPLOYDIR}/uImage-${KERNEL_IMAGE_NAME}.bin ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
        else
            echo "NOT 3 FOUND!"
        fi

        # copy initramfs image over initramfsless image - why?
        # because we need a proper init script to handle overlayfs

        echo "INITRAMFS IMAGE NAME = ${DEPLOYDIR}/uImage-initramfs-${MACHINE}.bin"

        if [ -f ${DEPLOYDIR}/uImage-initramfs-${MACHINE}.bin ]; then
            if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL} ]; then
                rm ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
            fi
            cp -L ${DEPLOYDIR}/uImage-initramfs-${MACHINE}.bin ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
        fi
    done
}

# 1. copied the whole task from kernel.bbclass
# 2. replaced mv's with cp's - quick and dirty
# 3. added skipping of the extra compile step based on the file indicator
do_bundle_initramfs () {
	if [ ! -z "${INITRAMFS_IMAGE}" -a x"${INITRAMFS_IMAGE_BUNDLE}" = x1 ]; then
		echo "Creating a kernel image with a bundled initramfs..."
		copy_initramfs
		# Backing up kernel image relies on its type(regular file or symbolic link)
		tmp_path=""
		for imageType in ${KERNEL_IMAGETYPE_FOR_MAKE} ; do
			if [ -h ${KERNEL_OUTPUT_DIR}/$imageType ] ; then
				linkpath=`readlink -n ${KERNEL_OUTPUT_DIR}/$imageType`
				realpath=`readlink -fn ${KERNEL_OUTPUT_DIR}/$imageType`
				cp -f $realpath $realpath.bak
				tmp_path=$tmp_path" "$imageType"#"$linkpath"#"$realpath
			elif [ -f ${KERNEL_OUTPUT_DIR}/$imageType ]; then
				cp -f ${KERNEL_OUTPUT_DIR}/$imageType ${KERNEL_OUTPUT_DIR}/$imageType.bak
				tmp_path=$tmp_path" "$imageType"##"
			fi
		done
		use_alternate_initrd=CONFIG_INITRAMFS_SOURCE=${B}/usr/${INITRAMFS_IMAGE_NAME}.cpio

		if [ -f "${WORKDIR}/initramfs_is_bundled" ]; then
			echo "There was an old initramfs. It got bundled with the kernel. Skipping to save time."
                else
			kernel_do_compile
		fi

		# Restoring kernel image
		for tp in $tmp_path ; do
			imageType=`echo $tp|cut -d "#" -f 1`
			linkpath=`echo $tp|cut -d "#" -f 2`
			realpath=`echo $tp|cut -d "#" -f 3`
			if [ -n "$realpath" ]; then
				cp -f $realpath $realpath.initramfs
				cp -f $realpath.bak $realpath
				ln -sf $linkpath.initramfs ${B}/${KERNEL_OUTPUT_DIR}/$imageType.initramfs
			else
				cp -f ${KERNEL_OUTPUT_DIR}/$imageType ${KERNEL_OUTPUT_DIR}/$imageType.initramfs
				cp -f ${KERNEL_OUTPUT_DIR}/$imageType.bak ${KERNEL_OUTPUT_DIR}/$imageType
			fi
		done
	fi
}

kernel_do_compile_prepend() {

	# 1. Docs: https://www.yoctoproject.org/docs/2.7.1/mega-manual/mega-manual.html#var-INITRAMFS_IMAGE_BUNDLE
	#
	# 2. ${INITRAMFS_TASK}"!="" - is some kind of an inactive old branch.
	#
	# 3. Our initramfs does not include any kernel modules so, we can
	#    reuse an old one and this will save a lot of time (around 2-3x times quicker)

	if [ "$use_alternate_initrd" = "" ] && [ "${INITRAMFS_IMAGE_BUNDLE}" = "1" ] ; then
		# if it was built at some point - just bundle whatever is there
		if [ ! -f ${B}/usr/${INITRAMFS_IMAGE}-${MACHINE}.cpio ] ; then
			echo "${INITRAMFS_IMAGE}-${MACHINE}.cpio is not found"
			echo "Unfortunately we will have to rebuild it and bundle in the do_bundle_initramfs task"
			echo "This will take a ton of time... :("
		else
			echo "There's the old ${INITRAMFS_IMAGE}-${MACHINE}.cpio from a previous build"
			echo "Let's happily bundle it and save a lot of time."
			copy_initramfs
			use_alternate_initrd=CONFIG_INITRAMFS_SOURCE=${B}/usr/${INITRAMFS_IMAGE_NAME}.cpio
			# indicate to do_bundle_initramfs() task that initramfs was bundled
			touch "${WORKDIR}/initramfs_is_bundled"
		fi
	fi
}

inherit elphel-misc-functions

VPATH = "${DEV_DIR}"
VFILE = "VERSION"

ELPHEL_PE = "${@version_update('${VPATH}','${VFILE}',0)}"
ELPHEL_PV = "${@version_update('${VPATH}','${VFILE}',1)}"
ELPHEL_PR = "${@version_update('${VPATH}','${VFILE}',2)}"

#FILES_kernel-image += " /etc/*"
FILES_${KERNEL_PACKAGE_NAME}-image += " /etc/*"

do_install_append() {
    install -d ${D}/etc/elphel393/packages
    echo "${ELPHEL_PE}.${ELPHEL_PV}.${ELPHEL_PR}" > ${D}/etc/elphel393/packages/linux-elphel

    echo "installing headers to ${WORKDIR}/headers"
    make headers_install INSTALL_HDR_PATH="${WORKDIR}/headers"
}

#do_populate_sysroot[sstate-outputdirs] = "${STAGING_DIR_TARGET}-uapi/"

sysroot_stage_all_append() {
    #sysroot_stage_dir ${WORKDIR}/headers/include ${STAGING_DIR_TARGET}/usr/include-uapi
    # Elphel, Rocko, new:
    sysroot_stage_dir ${WORKDIR}/headers/include ${SYSROOT_DESTDIR}/usr/include-uapi
}

## And you'd then use -I=/usr/myheaders/include to reference the sysroot
## copy of those headers.

REMOTE_USER ??= "root"
IDENTITY_FILE ??= "~/.ssh/id_rsa"
REMOTE_IP ??= "192.168.0.9"

do_target_scp () {
    echo "scp -i ${IDENTITY_FILE} -p ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL} ${REMOTE_USER}@${REMOTE_IP}:/mnt/mmc/${PRODUCTION_KERNEL}"
    scp -i ${IDENTITY_FILE} -p ${DEPLOY_DIR_IMAGE}/mmc/${PRODUCTION_KERNEL} ${REMOTE_USER}@${REMOTE_IP}:/mnt/mmc/${PRODUCTION_KERNEL}

    scp -i ${IDENTITY_FILE} -p ${WORKDIR}/image/etc/elphel393/packages/linux-elphel ${REMOTE_USER}@${REMOTE_IP}:/etc/elphel393/packages

    ssh -i ${IDENTITY_FILE} ${REMOTE_USER}@${REMOTE_IP} sync
}

addtask do_target_scp after do_deploy

do_target_scp[doc] = "scp copied the kernel to REMOTE_PATH on the target. REMOTE_USER and REMOTE_IP should be defined (ssh-copy-id -i KEY.pub TARGET_USER@TARGET_IP should be issued once)"

# works but useless
#_MAKEFLAGS_prepend = "--debug=v "

do_compile_append(){

    # this should help with "fixdep: permission denied"
    #rm -rf ${WORKDIR}/linux-${MACHINE}-standard-build/scripts/basic

}
