# Well

# returns string - based on file
def version_update(path,file,evr):
    import os.path
    if not os.path.exists(path+'/'+file):
        return 0
        
    f=open(path+'/'+file)
    for line in f:
        line = line.strip()
        if (line[0]!="#"):
            break
    arr = line.split('.')
    try:
        arr[evr]
    except IndexError:
        if (evr==1): res = 0
        if (evr==2): res = revision_update(path,file)
    else:
        res = arr[evr]
    f.close()
    return res
    
def revision_update(path,file):
    import subprocess
    cmd = "cd "+path+"; git rev-list --count $(git log -1 --pretty=format:\"%H\" "+file+")..HEAD"
    try:
        res = subprocess.check_output(cmd,stderr=subprocess.STDOUT,shell=True)
    except subprocess.CalledProcessError as e:
        res = "error_"+e.returncode
    res = str(int(res))
    res = res.strip(' \t\n\r')
    return res

VFILE = "VERSION"
PE = "${@version_update('${VPATH}','${VFILE}',0)}"
PV = "${@version_update('${VPATH}','${VFILE}',1)}"
PR = "${@version_update('${VPATH}','${VFILE}',2)}"

#SRCREV = "${PE}.${PV}.${PR}"
#SRCPV = "${PE}.${PV}.${PR}"
#SRCPV = "${AUTOREV}"
#__BB_DONT_CACHE = "1"

SRCREV = "${AUTOREV}"

#always start from compile
#do_compile[nostamp]="1"

FILESEXTRAPATHS_append := "${VPATH}:"
