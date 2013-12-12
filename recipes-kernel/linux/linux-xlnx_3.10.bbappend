FILESEXTRAPATHS_append := "${THISDIR}/linux-xlnx:"

SRC_URI_append += " file://xilinx_nandps_elphel393.patch"
SRC_URI_append += " file://xilinx_emacps.c.patch"
SRC_URI_append += " file://vsc3304.patch"

# Kernel version and SRCREV correspond to: 
# github.com/Xilinx/linux-xlnx.git xilinx-v14.7 tag 
SRCREV = "efc27505715e64526653f35274717c0fc56491e3"
