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
    import subprocess, os# , pwd for some reasons  pwd.getpwall() show some 3-user default, so read and parse etc/passwd
    pef = None # , preexec_fn=pefuid
    if (os.getuid() == 0):
        uname = os.getlogin()
        with open("/etc/passwd") as f:
            for line in f:
                line = line.strip()
                a = line.split(':')
                if a[0] == uname:
                    pef = preexec_fn=demote(int(a[3]),int(a[2]));    
                    break
    cmd = "cd "+path+"; git rev-list --count $(git log -1 --pretty=format:\"%H\" "+file+")..HEAD"
    try:
        res = subprocess.check_output(cmd,stderr=subprocess.STDOUT,shell=True, preexec_fn=pef)
    except subprocess.CalledProcessError as e:
        res = "error_"+e.returncode
    res = str(int(res))
    res = res.strip(' \t\n\r')
    return res

def demote(user_uid, user_gid):
    import os
    def result():
        os.setgid(user_gid)
        os.setuid(user_uid)
    return result
