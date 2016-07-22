FILESEXTRAPATHS_append := "${THISDIR}/linux-xlnx:"
FILESEXTRAPATHS_prepend := "${THISDIR}/config:"

SRC_URI_append += " file://pl35x_nand.c.patch"
SRC_URI_append += " file://xilinx_emacps.c.patch"
SRC_URI_append += " file://xilinx_uartps.c.patch"
SRC_URI_append += " file://si5338_vsc330x.patch"
SRC_URI_append += " file://drivers-elphel.patch"

SRC_URI_append += " file://${MACHINE}.scc"
KERNEL_FEATURES_append = " ${MACHINE}.scc"

linux-elphel_label= "git://github.com/Elphel/linux-elphel.git"
linux-elphel_branch= "master"
linux-elphel_gitdir= "${WORKDIR}/linux-elphel"

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
                os.system("cd ${S};ln -sf "+file_abspath+" "+file_relpath)
                    
        #os.system("cd ${DEV_DIR}; ln -sf ${S} linux")
        if not os.path.isdir("${DEV_DIR}/sysroots"):
                os.system("cd ${DEV_DIR}; ln -sf ${TOPDIR}/tmp/sysroots sysroots")
        if not os.path.isdir("${DEV_DIR}/linux"):
                os.system("cd ${DEV_DIR}; ln -sf ${WORKDIR}/linux-${MACHINE}-standard-build linux")
        os.system("cd ${DEV_DIR}/linux/source/kernel; ln -sf ${WORKDIR}/linux-${MACHINE}-standard-build/kernel/config_data.h config_data.h")
        os.system("cd ${DEV_DIR}/linux/source/kernel/time; ln -sf ${WORKDIR}/linux-${MACHINE}-standard-build/kernel/time/timeconst.h timeconst.h")
        os.system("cd ${DEV_DIR}/linux/source/lib; ln -sf ${WORKDIR}/linux-${MACHINE}-standard-build/lib/crc32table.h crc32table.h")
    else:
        print("Copying ${linux-elphel_gitdir}/src/ over ${S}\n")
        os.system("cp -rfv ${linux-elphel_gitdir}/src/* ${S}")
}

addtask do_link before do_kernel_configme after do_patch

do_deploy_append(){
    for RLOC in ${PRODUCTION_ROOT_LOCATION}; do
        if [ ! -d ${DEPLOY_DIR_IMAGE}/${RLOC} ]; then
            mkdir -p ${DEPLOY_DIR_IMAGE}/${RLOC}
        fi
        #if [ -f ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGE_BASE_NAME}.bin ]; then
        if [ -f ${DEPLOYDIR}/${KERNEL_IMAGE_BASE_NAME}.bin ]; then
            if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL} ]; then
                rm ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
            fi
            cp ${DEPLOYDIR}/${KERNEL_IMAGE_BASE_NAME}.bin ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
        else
            echo "NOT 3 FOUND!"
        fi
        #copy initramfs image over initramfsless image
        if [ -f ${DEPLOYDIR}/${INITRAMFS_BASE_NAME}.bin ]; then
            if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL} ]; then
                rm ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
            fi
            cp ${DEPLOYDIR}/${INITRAMFS_BASE_NAME}.bin ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_KERNEL}
        fi
    done
}

# Override do_bundle_initramfs (kernel.bbclass)
do_bundle_initramfs () {
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
