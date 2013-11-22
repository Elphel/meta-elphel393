FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# alarm didn't work in Kubuntu 13.10 (gcc-4.8.1?)
SRC_URI_append = "file://sleep.m4.patch"