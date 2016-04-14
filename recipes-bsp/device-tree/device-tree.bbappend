# add dtsi's
SRC_URI += "file://*.dtsi"

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
			ln -sf ${WORKDIR}/devicetree/bootargs-${RLOC}.dtsi ${WORKDIR}/devicetree/bootargs.dtsi
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