# Well

# returns string - based on file
def version_update(path,file):
    with open(path+'/'+file, 'r') as content_file:
        content = content_file.read()
        content = content.strip(' \t\n\r')
    return content

def revision_update(path,file):
    import subprocess
    cmd = "cd "+path+"; git rev-list --count $(git log -1 --pretty=format:\"%H\" "+file+")..HEAD"
    try:
        res = subprocess.check_output(cmd,stderr=subprocess.STDOUT,shell=True)
    except subprocess.CalledProcessError as e:
        res = "error_"+e.returncode
    res = res.strip(' \t\n\r')
    return res
