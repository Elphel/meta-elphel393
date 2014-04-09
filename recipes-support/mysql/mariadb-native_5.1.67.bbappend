# Copied the patch to fix building in Ubuntu 13.10
# link: http://lists.openembedded.org/pipermail/openembedded-devel/2013-December/093379.html
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append += "file://fix-link-error-ub1310.patch "
