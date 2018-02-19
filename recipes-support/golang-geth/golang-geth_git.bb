inherit golang

GO_SRCROOT = "github.com/ethereum/go-ethereum"

SUMMARY = "Go Ethereum"
DESCRIPTION = ""

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/"

LICENSE = "LGPLv3"
LIC_FILES_CHKSUM = "file://${GO_SRCROOT}/COPYING;md5=1f167b3d797139acbd8dcc90fe722510"

#SRCREV = "9d187f02389ba12493112c7feb15a83f44e3a3ff"
SRCREV = "1e67410e88d2685bc54611a7c9f75c327b553ccc"
SRC_URI = "git://${GO_SRCROOT};protocol=git"

PTEST_ENABLED = ""

LDFLAGS += "-pthread"

RDEPENDS_${PN}-dev += "bash gawk"
