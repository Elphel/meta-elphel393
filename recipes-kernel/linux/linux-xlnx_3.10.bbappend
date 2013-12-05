FILESEXTRAPATHS_append := "${THISDIR}/linux-xlnx:"

SRC_URI_append += " file://xilinx_nandps_elphel393.patch"
SRC_URI_append += " file://xilinx_emacps.c.patch"
SRC_URI_append += " file://vsc3304.patch"

# Kernel version and SRCREV correspond to: 
# github.com/Xilinx/linux-xlnx.git xilinx-v14.7 tag 
LINUX_VERSION = "3.10"
SRCREV = "efc27505715e64526653f35274717c0fc56491e3"

#inherit xilinx-utils
#FILESEXTRAPATHS_append := "${@get_additional_bbpath_filespath('conf/machine/boards:', d)}"

#OOT_KERNEL_DEVICETREE_append := "${@expand_dir_basepaths_by_extension("MACHINE_DEVICETREE", os.path.join(d.getVar("WORKDIR", True), 'devicetree'), '.dts', d)}"
