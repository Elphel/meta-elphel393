FILESEXTRAPATHS_append := "${TOPDIR}/../../linux-elphel/src/patches:"
FILESEXTRAPATHS_prepend := "${THISDIR}/config:"

SRC_URI_append += " file://garmin_usb.c.patch"
#SRC_URI_append += " file://xilinx_emacps.c.patch"
#SRC_URI_append += " file://xilinx_uartps.c.patch"
SRC_URI_append += " file://si5338_vsc330x.patch"
SRC_URI_append += " file://drivers-elphel.patch"
SRC_URI_append += " file://ahci.patch"
SRC_URI_append += " file://libahci.patch"
SRC_URI_append += " file://libata-eh.c.patch"

SRC_URI_append += " file://${MACHINE}.scc"
KERNEL_FEATURES_append = " ${MACHINE}.scc"

ELPHELGITHOST ??= "git.elphel.com"

linux-elphel_label= "https://${ELPHELGITHOST}/Elphel/linux-elphel.git"
linux-elphel_branch= "master"
linux-elphel_gitdir= "${WORKDIR}/linux-elphel"

# linux xilinx hash
SRCREV = "9c2e29b2c81dbb1efb7ee4944b18e12226b97513"

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

        if [ -f ${DEPLOYDIR}/uImage-${KERNEL_IMAGE_BASE_NAME}.bin ]; then
            if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL} ]; then
                rm ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
            fi
            cp ${DEPLOYDIR}/uImage-${KERNEL_IMAGE_BASE_NAME}.bin ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
        else
            echo "NOT 3 FOUND!"
        fi

        # copy initramfs image over initramfsless image - why?

        if [ -f ${DEPLOYDIR}/uImage-${INITRAMFS_BASE_NAME}.bin ]; then
            if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL} ]; then
                rm ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
            fi
            cp ${DEPLOYDIR}/uImage-${INITRAMFS_BASE_NAME}.bin ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
        fi
    done
}

# OLD: Override do_bundle_initramfs (kernel.bbclass)
do_bundle_initramfs_old () {
	if [ ! -z "${INITRAMFS_IMAGE}" -a x"${INITRAMFS_IMAGE_BUNDLE}" = x1 ]; then
		echo "Creating a kernel image with a bundled initramfs..."
		copy_initramfs
		#if [ -e ${KERNEL_OUTPUT} ] ; then
		#	mv -f ${KERNEL_OUTPUT} ${KERNEL_OUTPUT}.bak
		#fi
		#use_alternate_initrd=CONFIG_INITRAMFS_SOURCE=${B}/usr/${INITRAMFS_IMAGE}-$#{MACHINE}.cpio
		#kernel_do_compile
		cp ${KERNEL_OUTPUT} ${KERNEL_OUTPUT}.initramfs
		#mv -f ${KERNEL_OUTPUT}.bak ${KERNEL_OUTPUT}
		# Update install area
		echo "There is kernel image bundled with initramfs: ${B}/${KERNEL_OUTPUT}.initramfs"
		install -m 0644 ${B}/${KERNEL_OUTPUT}.initramfs ${D}/boot/${KERNEL_IMAGETYPE}-initramfs-${MACHINE}.bin
		echo "${B}/${KERNEL_OUTPUT}.initramfs"
	fi
}

# Override kernel_do_compile used by do_bundle_initramfs in kernel.bbclass
# Added ${PARALLEL_MAKE} only
kernel_do_compile() {
	unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MACHINE

	# The $use_alternate_initrd is only set from
	# do_bundle_initramfs() This variable is specifically for the
	# case where we are making a second pass at the kernel
	# compilation and we want to force the kernel build to use a
	# different initramfs image.  The way to do that in the kernel
	# is to specify:
	# make ...args... CONFIG_INITRAMFS_SOURCE=some_other_initramfs.cpio
	if [ "${INITRAMFS_IMAGE_BUNDLE}" = "1" ] ; then
                echo "ONLY ONE RUN!"
		# The old style way of copying an prebuilt image and building it
		# is turned on via INTIRAMFS_TASK != ""
		copy_initramfs
		if [ ! -f ${B}/usr/${INITRAMFS_IMAGE}-${MACHINE}.cpio ] ; then
                    echo "This might be the very first kernel build (or deploy dir is empty) - initramfs is not there yet. Will have to compile kernel twice"
                    #oe_runmake ${KERNEL_IMAGETYPE_FOR_MAKE} ${PARALLEL_MAKE} ${KERNEL_ALT_IMAGETYPE} CC="${KERNEL_CC}" LD="${KERNEL_LD}" ${KERNEL_EXTRA_ARGS}
                else
                    use_alternate_initrd=CONFIG_INITRAMFS_SOURCE=${B}/usr/${INITRAMFS_IMAGE}-${MACHINE}.cpio
                fi
        fi
        oe_runmake ${KERNEL_IMAGETYPE_FOR_MAKE} ${PARALLEL_MAKE} ${KERNEL_ALT_IMAGETYPE} CC="${KERNEL_CC}" LD="${KERNEL_LD}" ${KERNEL_EXTRA_ARGS} $use_alternate_initrd
	if test "${KERNEL_IMAGETYPE_FOR_MAKE}.gz" = "${KERNEL_IMAGETYPE}"; then
		gzip -9c < "${KERNEL_IMAGETYPE_FOR_MAKE}" > "${KERNEL_OUTPUT}"
	fi
}

inherit elphel-misc-functions

VPATH = "${DEV_DIR}"
VFILE = "VERSION"

ELPHEL_PE = "${@version_update('${VPATH}','${VFILE}',0)}"
ELPHEL_PV = "${@version_update('${VPATH}','${VFILE}',1)}"
ELPHEL_PR = "${@version_update('${VPATH}','${VFILE}',2)}"

FILES_kernel-image += " /etc/*"

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
