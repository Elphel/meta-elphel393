SUMMARY = "helper script"
DESCRIPTION = "compare built versions with the ones on the target system"

AUTHOR = "Elphel Inc."
HOMEPAGE = "http://www3.elphel.com/" 

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0;md5=c79ff39f19dfec6d293b95dea7b07891"

deltask do_fetch
deltask do_unpack
deltask do_patch
deltask do_configure 
deltask do_compile 
deltask do_install 
deltask do_populate_sysroot
deltask do_populate_lic 
deltask do_rm_work
#deltask do_build

inherit nopackages

INHIBIT_DEFAULT_DEPS = "1"
DEPENDS = ""
PACKAGES = ""

do_run[nostamp] = "1"

VPATH = "${TOPDIR}/../../tools/elphel-tools-update"

python do_run(){

  import os
  import subprocess

  VPATH = d.getVar('VPATH'  , True)
  DEPLOY_DIR_IMAGE = d.getVar('DEPLOY_DIR_IMAGE'  , True)
  # mmc
  PRODUCTION_DIR = d.getVar('PRODUCTION_DIR'  , True)
  
  for file in os.listdir(VPATH):
      fname,fext = os.path.splitext(file)
      if fext==".py":
        #create link
        if os.path.isfile(DEPLOY_DIR_IMAGE+"/"+PRODUCTION_DIR+"/"+file):
          cmd = "rm "+DEPLOY_DIR_IMAGE+"/"+PRODUCTION_DIR+"/"+file
          subprocess.call(cmd,shell=True)
        cmd = "ln -sf "+VPATH+"/"+file+" "+DEPLOY_DIR_IMAGE+"/"+PRODUCTION_DIR
        subprocess.call(cmd,shell=True)
}

addtask do_run before do_build