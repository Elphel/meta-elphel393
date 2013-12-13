FILESEXTRAPATHS_append := "${THISDIR}/linux-xlnx:"

SRC_URI_append += " file://xilinx_nandps_elphel393.patch"
SRC_URI_append += " file://xilinx_emacps.c.patch"
SRC_URI_append += " file://si5338_vsc330x.patch"

# Kernel version and SRCREV correspond to: 
# github.com/Xilinx/linux-xlnx.git xilinx-v14.7 tag 
SRCREV = "efc27505715e64526653f35274717c0fc56491e3"

linux-elphel_label= "git://git.code.sf.net/p/elphel/linux-elphel"
linux-elphel_branch= "master"
linux-elphel_gitdir= "${WORKDIR}/linux-elphel"

do_fetch_append() {
    print("Cloninig ${linux-elphel_label}\n")
    os.system("git clone -b ${linux-elphel_branch} ${linux-elphel_label} ${linux-elphel_gitdir}")
}

do_unpack_append() {
    print("Copying ${linux-elphel_gitdir} over ${S}\n")
    os.system("cp -rf ${linux-elphel_gitdir}/* ${S}")
}