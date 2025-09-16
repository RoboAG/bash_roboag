import os
import sys
import subprocess

path = os.path.dirname(os.path.abspath(__file__))

pkgdir = path + "/../system_config/install"
pkgdir = os.path.abspath(pkgdir)

def _readpackages(server = False, uninstall = False,debug = False):
    ### READ FILE DATA ###
    filename = "common" if server == False else "server"
    uninstallpath = "" if uninstall == False else "uninstall_"
    filepath = pkgdir + "/" + uninstallpath + filename + ".txt"
    if debug:
        print("reading: " + filepath)

    with open(filepath) as file:
        data = file.readlines()

    if debug:
        print("filecontent:\n", data)
        
    ###PARSE FILE DATA ###

    pkgs = ""
    for line in data:
        if line.strip() == "" or line.strip()[0] == "#":
            continue
        for pkg in line.strip().split(" "):
            pkgs += " " + pkg

    return pkgs[1:]

def DoFullUpdate(server = False, debug = False):
    if debug:
        print("###DEBUG MODE, NO CHANGES ARE MADE")

    pkgs = _readpackages(server=server, uninstall=False, debug=debug)
    if debug:
        print("install cmd:", "apt", "install", pkgs)
    else:
        subprocess.run(["apt", "install", pkgs])

    pkgs = _readpackages(server=server, uninstall=True, debug=debug)
    if debug:
        print("remove cmd:", "apt", "remove", pkgs)
    else:
        subprocess.run(["apt", "remove", pkgs])

def help():
    print("this is the packagemanager :)")
    print("usage: pkgmanager [flags] <pkg>")
    print("note: if -a/-r is set use -u to update/install")
    print("      else no changes are made")
    print("      e.g. pkgmanager -au git")
    print("-a: add a pkg")
    print("-r: remove a pkg")
    print("-y: autorun")
    print("-d: debug mode, no changes")
    print("-h: show this help")
    print("-u: update all pkgs")

def managepkg(server = False, uninstall = False, debug = False, autorun = False, package="neovim"):
    filename = "common" if server == False else "server"
    uninstallpath = pkgdir + "/" + "uninstall_" + filename + ".txt"
    installpath = pkgdir + "/" + filename + ".txt"
    
    if debug:
        print("reading:")
        print(installpath)
        print(uninstallpath)

    with open(installpath, "r") as f:
        installdata = f.readlines()
    
    with open(uninstallpath, "r") as f:
        uninstalldata = f.readlines()

    # find where pkg is in install/uninstall
    installidx = -1
    uninstallidx = -1
    for i, line in enumerate(installdata):
        if line.strip() == "" or line.strip()[0] == "#":
            continue
        if package in line:
            installidx = i
    
    for i, line in enumerate(uninstalldata):
        if line.strip() == "" or line.strip()[0] == "":
            continue
        if package in line:
            uninstallidx = i
    
    if uninstall:
        if installidx != -1:
            line = installdata[installidx]
            line = line.split(" ")
            line[-1] = line[-1][:-1]
            try:
                idx = line.index(package)
            except ValueError as e:
                print("smthing went wrong: ")
                print(e)
                print(f"tried to read line: {installidx}")
                print(f"which contained: {line}")
                sys.exit()
            line.pop(idx)
            line = " ".join(line)
            writedata = installdata
            writedata[installidx] = line
            if not debug:
                with open(installpath, "rw") as f:
                    f.writelines(writedata)
            else:
                print("writing: ")
                print(writedata)

args = sys.argv[1:]
if args == []:
    help()#
    sys.exit()
flags = args[0][1:]
debug = False
add = False
remove = False
autorun = False
update = False
for flag in flags:
    match flag:
        case "a":
            add = True
        case "r":
            remove = True
        case "d":
            debug = True
        case "y":
            autorun = True
        case "u":
            update = True
        case "h":
            help()
            sys.exit()
        case _:
            help()
            sys.exit()#

if add and remove:
    print("sry but you cant add and remove a pkg at the same time :-(")
    sys.exit()

managepkg(server = False,debug=True, uninstall=True)
