SUMMARY = "helper script"
DESCRIPTION = "update all"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

PRIORITY = "optional"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://LICENSE;beginline=21;endline=699;md5=ccd2fef7dee090f3b211c6677c3e34cc"

SRCDATE = "20160405"

PV = "${SRCDATE}"
PR = "r0"

SRC_URI = "file://LICENSE"

S = "${WORKDIR}/"

DEV_DIR = "${TOPDIR}/.."

R0 = "meta-elphel393"
R1 = "meta-ezynq"
R2 = "linux-elphel"
R3 = "../x393"
R4 = "../x393_sata"

addtask pull

do_pull(){
	for REP in ${R0} ${R1} ${R2} ${R3} ${R4}
	do
		echo "${REP}"
		if [ -d ${DEV_DIR}/${REP} ]; then
			echo "updating ${REP}"
			cd ${DEV_DIR}/${REP}; git pull
		fi
	done
}