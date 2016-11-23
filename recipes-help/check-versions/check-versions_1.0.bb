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

inherit elphel-ssh elphel-misc
PE = "1"
PV = "0"
PR = "0"

INHIBIT_DEFAULT_DEPS = "1"
DEPENDS = ""
PACKAGES = ""

do_run[nostamp] = "1"

python do_run(){

  user = d.getVar('REMOTE_USER', True) 
  ip   = d.getVar('REMOTE_IP', True)

  # all hardcoded
  pdir = "/etc/elphel393/packages"
  localpdir = "rootfs-elphel"
  imagedir = "image"
  topdir = d.getVar('TOPDIR', True)+"/../../"
  projects_list = topdir+"projects.json"
  
  print("Checking packages' versions - locally built vs installed on the remote system")
  print("    Remote system: "+user+"@"+ip)
  print("    Get remote package list")
  
  ispdir = command_over_ssh(d,"'if [ -d "+pdir+" ]; then echo 1; else echo 0;fi'")
  
  remote_list = []
  
  if ispdir=="1":
    # print remote package list
    tmp_str = command_over_ssh(d,"'ls "+pdir+"'")
    print(tmp_str)
    
    tmp_list = tmp_str.split()
    for elem in tmp_list:
      remote_list.append([elem,command_over_ssh(d,"'cat "+pdir+"/"+elem+"'")])
      
  else:
    raise Exception("\033[1;37m"+user+"@"+ip+":"+pdir+": No such file or directory\033[0m")
  
  # projects_list/remote_list/
  import json
  
  with open(projects_list) as data_file:
    Projects = json.load(data_file)
    
  for p,v in Projects.items():
    if p==localpdir:
      for k,l in v.items():
        print("Project: "+k)
        tmp_path = topdir+localpdir+"/"+k
        if (os.path.isdir(tmp_path)):
          if (os.path.isdir(tmp_path+"/"+imagedir+pdir)):
            for root,dir,files in os.walk(tmp_path+"/"+imagedir+pdir):
              for name in files:
              
                with open(tmp_path+"/"+imagedir+pdir+"/"+name, 'r') as content_file:
                  built_v = content_file.read()
              
                built_pv = [name,built_v.strip()]
                #get source version
                tmp_v = version_update(tmp_path,"VERSION",0)+"."+version_update(tmp_path,"VERSION",1)+"."+version_update(tmp_path,"VERSION",2)
                source_pv = [built_pv[0],tmp_v]
                
                if built_pv[1]==source_pv[1]:
                  print("Source version matches built version")
                else:
                  bb.warn("project "+k+": source and built versions do not match: source="+source_pv[1]+" vs built="+built_pv[1])
                
                for remote_pv in remote_list:
                  if remote_pv[0]==built_pv[0]:
                    print("Names match")
                    if remote_pv[1]==built_pv[1]:
                      print("    versions match: "+remote_pv[1])
                    else:
                      bb.warn("project "+k+": package versions do not match, local: "+built_pv[1]+" vs remote: "+remote_pv[1])
          else:
            bb.warn("project "+k+" is not built or too old")
            #raise Exception("\033[1;37mproject is not built\033[0m")
        else:
          bb.warn("project "+k+" is missing")
          #raise Exception("\033[1;37mproject is missing\033[0m")

}

addtask do_run before do_build
