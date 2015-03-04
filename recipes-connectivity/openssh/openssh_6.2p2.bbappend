FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

#pre-generated keys
SRC_URI_append = " file://ssh_host_dsa_key_default \
                   file://ssh_host_dsa_key_default.pub \
                   file://ssh_host_ecdsa_key_default \
                   file://ssh_host_ecdsa_key_default.pub \
                   file://ssh_host_rsa_key_default \
                   file://ssh_host_rsa_key_default.pub \
                 "

do_install_append() {
    install -m 0600 ${WORKDIR}/ssh_host_dsa_key_default ${D}${sysconfdir}/ssh/ssh_host_dsa_key
    install -m 0644 ${WORKDIR}/ssh_host_dsa_key_default.pub ${D}${sysconfdir}/ssh/ssh_host_dsa_key.pub
    install -m 0600 ${WORKDIR}/ssh_host_ecdsa_key_default ${D}${sysconfdir}/ssh/ssh_host_ecdsa_key
    install -m 0644 ${WORKDIR}/ssh_host_ecdsa_key_default.pub ${D}${sysconfdir}/ssh/ssh_host_ecdsa_key.pub
    install -m 0600 ${WORKDIR}/ssh_host_rsa_key_default ${D}${sysconfdir}/ssh/ssh_host_rsa_key
    install -m 0644 ${WORKDIR}/ssh_host_rsa_key_default.pub ${D}${sysconfdir}/ssh/ssh_host_rsa_key.pub
}
