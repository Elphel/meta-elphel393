# append to recipe: meta-openembedded/meta-networking/recipes-support/ntp/...

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# is not needed in ROCKO

#EXTRA_OECONF += "--libexecdir=/usr/lib/ntp \
#		"