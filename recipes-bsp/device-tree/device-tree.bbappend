 
do_deploy_append(){
	ln -sf ${DEPLOY_DIR_IMAGE}/${DTS_NAME}.dtb ${DEPLOY_DIR_IMAGE}/devicetree.dtb
}