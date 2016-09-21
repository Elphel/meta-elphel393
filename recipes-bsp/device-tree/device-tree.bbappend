# add dtsi's

FILESEXTRAPATHS_append := "${TOPDIR}/../../linux-elphel/src/arch/arm/boot/dts:"

SRC_URI += "file://elphel393.dts \
            file://elphel393-zynq-base.dtsi \
            file://elphel393-bootargs-mmc.dtsi \
            file://elphel393-bootargs-nand.dtsi \
            file://elphel393-bootargs-ram.dtsi \
            "

MACHINE_DEVICETREE := "\
                       elphel393.dts \
                      "

do_deploy(){
	for DTS_FILE in ${DEVICETREE}; do
		DTS_NAME=`basename ${DTS_FILE} | awk -F "." '{print $1}'`
		for RLOC in ${PRODUCTION_ROOT_LOCATION}; do
			if [ ! -f ${WORKDIR}/${DTS_NAME}_${RLOC}.dtb ]; then
				echo "Warning: ${WORKDIR}/${DTS_NAME}_${RLOC}.dtb is not available!"
				continue
			fi
		
			install -d ${DEPLOY_DIR_IMAGE}
			install -m 0644 ${B}/${DTS_NAME}_${RLOC}.dtb ${DEPLOY_DIR_IMAGE}/${DTS_NAME}_${RLOC}.dtb
		
			echo "RootFS located in ${RLOC}"
			if [ ! -d ${DEPLOY_DIR_IMAGE}/${RLOC} ]; then
				mkdir ${DEPLOY_DIR_IMAGE}/${RLOC}
			fi
			if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_DEVICETREE} ]; then
				rm ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_DEVICETREE}
			fi
			
			cp ${DEPLOY_DIR_IMAGE}/${MACHINE}_${RLOC}.dtb ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_DEVICETREE}
		done
	done
}

# full sub
do_compile() {
	if test -n "${MACHINE_DEVICETREE}"; then
		mkdir -p ${WORKDIR}/devicetree
		for i in ${MACHINE_DEVICETREE}; do
			if test -e ${WORKDIR}/$i; then
				echo cp ${WORKDIR}/$i ${WORKDIR}/devicetree
				cp ${WORKDIR}/$i ${WORKDIR}/devicetree
				cp ${WORKDIR}/*.dtsi ${WORKDIR}/devicetree
			fi
		done
	fi

	for DTS_FILE in ${DEVICETREE}; do
		DTS_NAME=`basename ${DTS_FILE} | awk -F "." '{print $1}'`
		for RLOC in ${PRODUCTION_ROOT_LOCATION}; do
			ln -sf ${WORKDIR}/devicetree/elphel393-bootargs-${RLOC}.dtsi ${WORKDIR}/devicetree/elphel393-bootargs.dtsi
			dtc -I dts -O dtb ${DEVICETREE_FLAGS} -o ${DTS_NAME}_${RLOC}.dtb ${DTS_FILE}
		done
	done
}

# full sub
do_install() {
	for DTS_FILE in ${DEVICETREE}; do
		DTS_NAME=`basename ${DTS_FILE} | awk -F "." '{print $1}'`
		for RLOC in ${PRODUCTION_ROOT_LOCATION}; do
			if [ ! -f ${WORKDIR}/${DTS_NAME}_${RLOC}.dtb ]; then
				echo "Warning: ${DTS_NAME}_${RLOC}.dtb is not available!"
				continue
			fi
			install -d ${D}/boot/devicetree
			install -m 0644 ${B}/${DTS_NAME}_${RLOC}.dtb ${D}/boot/devicetree/${DTS_NAME}_${RLOC}.dtb
		done
	done
}

REMOTE_USER ??= "root"
IDENTITY_FILE ??= "~/.ssh/id_rsa"
REMOTE_IP ??= "192.168.0.9"

do_target_scp () {
    # mmc device tree only
    echo "scp -i ${IDENTITY_FILE} -p ${DEPLOY_DIR_IMAGE}/${MACHINE}_mmc.dtb ${REMOTE_USER}@${REMOTE_IP}:/mnt/mmc/devicetree.dtb"
    scp -i ${IDENTITY_FILE} -p ${DEPLOY_DIR_IMAGE}/${MACHINE}_mmc.dtb ${REMOTE_USER}@${REMOTE_IP}:/mnt/mmc/devicetree.dtb
    ssh -i ${IDENTITY_FILE} ${REMOTE_USER}@${REMOTE_IP} sync
}

addtask do_target_scp after do_deploy

do_target_scp[doc] = "scp copied device tree to REMOTE_PATH on the target. REMOTE_USER and REMOTE_IP should be defined (ssh-copy-id -i KEY.pub TARGET_USER@TARGET_IP should be issued once)"
