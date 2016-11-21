# Need this function in another reipe

def command_over_ssh(d,command):
    import subprocess
    user = d.getVar('REMOTE_USER', True)
    id = d.getVar('IDENTITY_FILE', True)
    ip = d.getVar('REMOTE_IP', True)
    cmd = "ssh -i "+id+" "+user+"@"+ip+" "+command
    print("cmd: "+cmd)
    try:
        ret = subprocess.check_output(cmd,stderr=subprocess.STDOUT,shell=True)
    except subprocess.CalledProcessError:
        raise Exception("Copying to target requires access by public key. Run: \033[1;37mssh-copy-id "+REMOTE_USER+"@"+REMOTE_IP+"\033[0m")
        
    return ret.strip() 
