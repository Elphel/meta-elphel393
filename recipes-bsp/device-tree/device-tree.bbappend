 
do_deploy_append(){
	ln -sf ${DEPLOY_DIR_IMAGE}/${DTS_NAME}.dtb ${DEPLOY_DIR_IMAGE}/devicetree.dtb
	if [ ! -d ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR} ]; then
		mkdir ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}
	fi
	if [ -f ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_DEVICETREE} ]; then
		rm ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_DEVICETREE}
	fi
	cp ${DEPLOY_DIR_IMAGE}/${DTS_NAME}.dtb ${DEPLOY_DIR_IMAGE}/${PRODUCTION_DIR}/${PRODUCTION_DEVICETREE}
}