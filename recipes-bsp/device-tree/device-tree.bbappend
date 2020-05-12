# add dtsi's

FILESEXTRAPATHS_append := "${TOPDIR}/../../linux-elphel/src/arch/arm/boot/dts:"

MACHINE_DEVICETREE ?= "elphel393.dts"

COMPATIBLE_MACHINE_elphel393 = ".*"

# include all
# MACHINE_DEVICETREE - in case something new is added
SRC_URI += "file://${MACHINE_DEVICETREE} \
            file://elphel393_4_mt9p006.dts \
            file://elphel393_4_mt9f002.dts \
            file://elphel393_4_lepton35.dts \
            file://elphel393_eyesis.dts \
            file://elphel393_eyesis_bottom2.dts \
            file://elphel393-zynq-base.dtsi \
            file://elphel393-common.dtsi \
            file://elphel393-bootargs-mmc.dtsi \
            file://elphel393-bootargs-nand.dtsi \
            file://elphel393-bootargs-ram.dtsi \
            file://elphel393-revision-rev0-B.dtsi \
            file://elphel393-revision-revC.dtsi \
            "

do_deploy(){

	DTS_NAME=`basename ${MACHINE_DEVICETREE} | awk -F "." '{print $1}'`
	echo "Copying ${DTS_NAME} device tree to production locations"
	for RLOC in ${PRODUCTION_ROOT_LOCATION}; do
		if [ ! -f ${B}/${DTS_NAME}_${RLOC}.dtb ]; then
			echo "Warning: ${B}/${DTS_NAME}_${RLOC}.dtb is not available!"
			continue
		fi

		install -d ${DEPLOY_DIR_IMAGE}
		install -m 0644 ${B}/${DTS_NAME}_${RLOC}.dtb ${DEPLOY_DIR_IMAGE}/${DTS_NAME}_${RLOC}.dtb

		if [ ! -d ${DEPLOY_DIR_IMAGE}/${RLOC} ]; then
			mkdir ${DEPLOY_DIR_IMAGE}/${RLOC}
		fi
		if [ -f ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_DEVICETREE} ]; then
			rm ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_DEVICETREE}
		fi

		cp ${DEPLOY_DIR_IMAGE}/${DTS_NAME}_${RLOC}.dtb ${DEPLOY_DIR_IMAGE}/${RLOC}/${PRODUCTION_DEVICETREE}
		echo "Installed to ${DEPLOY_DIR_IMAGE}/${RLOC}/"
	done
}

python do_deploy(){

    import shutil

    B                        = d.getVar('B', True)
    DEPLOY_DIR_IMAGE         = d.getVar('DEPLOY_DIR_IMAGE', True)
    MACHINE_DEVICETREE       = d.getVar('MACHINE_DEVICETREE', True)
    PRODUCTION_DEVICETREE    = d.getVar('PRODUCTION_DEVICETREE', True)
    PRODUCTION_ROOT_LOCATION = d.getVar('PRODUCTION_ROOT_LOCATION', True)

    DTS_NAME = os.path.splitext(MACHINE_DEVICETREE)[0]
    BOARD_DEFAULT_REVISION = "revC"

    dtb_dir_path = os.path.join(DEPLOY_DIR_IMAGE,"dtb")
    os.makedirs(dtb_dir_path,exist_ok=True)
    for f in os.listdir(B):
        shutil.copyfile(os.path.join(B,f),os.path.join(dtb_dir_path,f))

    for RLOC in PRODUCTION_ROOT_LOCATION.split():

        if not DTS_NAME.startswith("elphel393_eyesis"):

            dtb_name = DTS_NAME+"_"+BOARD_DEFAULT_REVISION+"_"+RLOC+".dtb"
            dtb_path        = os.path.join(B,dtb_name)
            dtb_build_path  = os.path.join(DEPLOY_DIR_IMAGE,dtb_name)
            rloc_path       = os.path.join(DEPLOY_DIR_IMAGE,RLOC)
            dtb_deploy_path = os.path.join(rloc_path,PRODUCTION_DEVICETREE)

            if not os.path.exists(dtb_path):
                print("Warning: "+dtb_path+" is not available")

            os.system("install -d "+DEPLOY_DIR_IMAGE)
            os.system("install -m 0644 "+dtb_path+" "+dtb_build_path)

            os.makedirs(rloc_path,exist_ok=True)

            shutil.copyfile(dtb_build_path,dtb_deploy_path)

            print("Deployed "+dtb_deploy_path)

}

python do_compile(){

    WORKDIR                  = d.getVar('WORKDIR', True)
    PRODUCTION_ROOT_LOCATION = d.getVar('PRODUCTION_ROOT_LOCATION', True)
    DEVICETREE_FLAGS         = d.getVar('DEVICETREE_FLAGS', True)
    if DEVICETREE_FLAGS is None:
        DEVICETREE_FLAGS = ''

    for f in os.listdir(WORKDIR):
        if f.endswith(".dts"):

            DTS_NAME = os.path.splitext(f)[0]
            eyesis = False

            print("Found dts file: "+f)
            if f.startswith("elphel393_eyesis"):
                print("Device tree type: Eyesis4Pi 393 (panoramic camera)")
                eyesis = True
            else:
                print("Device tree type: 10393 (regular)")

            f = os.path.join(WORKDIR,f)

            if not eyesis:
                for RLOC in PRODUCTION_ROOT_LOCATION.split():
                    os.system("ln -sf "+WORKDIR+"/elphel393-bootargs-"+RLOC+".dtsi "+WORKDIR+"/elphel393-bootargs.dtsi")
                    for REV in ["rev0-B","revC"]:
                        os.system("ln -sf "+WORKDIR+"/elphel393-revision-"+REV+".dtsi "+WORKDIR+"/elphel393-revision.dtsi")
                        os.system("dtc -I dts -O dtb "+str(DEVICETREE_FLAGS)+" -o "+DTS_NAME+"_"+REV+"_"+RLOC+".dtb "+f)
            else:
                for RLOC in PRODUCTION_ROOT_LOCATION.split():
                    print("running: ")
                    print("dtc -I dts -O dtb "+str(DEVICETREE_FLAGS)+" -o "+DTS_NAME+"_"+RLOC+".dtb "+f)
                    os.system("ln -sf "+WORKDIR+"/elphel393-bootargs-"+RLOC+".dtsi "+WORKDIR+"/elphel393-bootargs.dtsi")
                    os.system("dtc -I dts -O dtb "+str(DEVICETREE_FLAGS)+" -o "+DTS_NAME+"_"+RLOC+".dtb "+f)
}

python do_install(){

    B = d.getVar('B', True)
    D = d.getVar('D', True)

    os.system("install -d "+D+"/boot/devicetree")

    for f in os.listdir(B):
        if not f.startswith("elphel393_eyesis"):
            src = B+"/"+f
            dst = D+"/boot/devicetree/"+f
            os.system("install -m 0644 "+src+" "+dst)
}

REMOTE_USER ??= "root"
IDENTITY_FILE ??= "~/.ssh/id_rsa"
REMOTE_IP ??= "192.168.0.9"

do_target_scp () {
    # mmc device tree only
    echo "scp -i ${IDENTITY_FILE} -p ${DEPLOY_DIR_IMAGE}/mmc/devicetree.dtb ${REMOTE_USER}@${REMOTE_IP}:/mnt/mmc"
    scp -i ${IDENTITY_FILE} -p ${DEPLOY_DIR_IMAGE}/mmc/devicetree.dtb ${REMOTE_USER}@${REMOTE_IP}:/mnt/mmc
    ssh -i ${IDENTITY_FILE} ${REMOTE_USER}@${REMOTE_IP} sync
}

addtask do_target_scp after do_deploy

do_target_scp[doc] = "scp copied device tree to REMOTE_PATH on the target. REMOTE_USER and REMOTE_IP should be defined (ssh-copy-id -i KEY.pub TARGET_USER@TARGET_IP should be issued once)"
