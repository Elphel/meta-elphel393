inherit xilinx-utils

# If OOT_KERNEL_DEVICETREE is not set, default to the device tree's provided by
# MACHINE_DEVICETREE
OOT_KERNEL_DEVICETREE ?= "${@expand_dir_basepaths_by_extension("MACHINE_DEVICETREE", os.path.join(d.getVar("WORKDIR", True), 'dts'), '.dts', d)}"

# Appends the '<layer>/conf/machine/boards' path to FILESEXTRAPATHS for all
# layers (using the ${BBPATH})
FILESEXTRAPATHS_append := "${@get_additional_bbpath_filespath('conf/machine/boards:', d)}"

# Using the MACHINE_DEVICETREE and MACHINE_KCONFIG vars, append them to SRC_URI
SRC_URI_append += " \
                ${@paths_affix(d.getVar("MACHINE_DEVICETREE", True) or '', prefix = 'file://')} \
                ${@paths_affix(d.getVar("MACHINE_KCONFIG", True) or '', prefix = 'file://')} \
                "

# Copy all device tree's into the same directory. This is due to compatibility
# with dtc and the use of DTSI (Device Tree Includes), the version of DTC in
# Yocto does not provide include path support.
do_install_prepend() {
	if test -n "${MACHINE_DEVICETREE}"; then
		mkdir -p ${WORKDIR}/devicetree
		for i in ${MACHINE_DEVICETREE}; do
			if test -e ${WORKDIR}/$i; then
				cp ${WORKDIR}/$i ${WORKDIR}/devicetree
			fi
		done
	fi
}