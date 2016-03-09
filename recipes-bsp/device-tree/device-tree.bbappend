do_deploy_append(){
	for RLOC in ${PRODUCTION_ROOT_LOCATION}; do
		echo "RootFS located in ${RLOC}"
		if [ ! -d ${DEPLOY_DIR_IMAGE}/${RLOC} ]; then
			mkdir ${DEPLOY_DIR_IMAGE}/${RLOC}
		fi
		if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_DEVICETREE} ]; then
			rm ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_DEVICETREE}
		fi
		cp ${DEPLOY_DIR_IMAGE}/${MACHINE}_${RLOC}.dtb ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_DEVICETREE}
	done
}