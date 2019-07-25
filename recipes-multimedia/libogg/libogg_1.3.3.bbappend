FILESEXTRAPATHS_prepend := "${THISDIR}/files:" 

SRC_URI_append +=   "file://framing.c.patch \
                    file://ogg.h.patch"