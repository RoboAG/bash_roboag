import os
import sys
import shutil
import time
import pwd
import grp

MEMBER_FOLDER_PATH = "/media/share/roboag/User"

def list_members():
    return os.listdir(MEMBER_FOLDER_PATH)

def create_member_folder(name):
    path = os.path.join(MEMBER_FOLDER_PATH, name)
    os.mkdir(path)
    os.mkdir(path + "/neu")

def chown(name = "roboag", group = "roboag", folder = ""):
    if folder == "":
        sys.exit("error: no folder given")

    userid = pwd.getpwnam(name).pw_uid
    groupid = grp.getgrnam(group).gr_gid
    
    for root, dirs, files in os.walk(folder):
        for name in dirs + files:
            os.chown(os.path.join(root, name), userid, groupid)

def create_member_neu_folder(name, debug = False):
    memberfolder = os.path.join(MEMBER_FOLDER_PATH, name)
    date = time.strftime("%Y_%m_%d_")
    
    if not debug:
        os.makedirs(memberfolder + "/neu", exist_ok = True)
        os.makedirs(memberfolder + f"/{date}", exist_ok = True)
    else:
        print("would create:")
        print(memberfolder + "/neu")
        print(memberfolder + f"/{date}")

    neucontent = os.listdir(memberfolder + "/neu/")
    if neucontent == []:
        print(name, "did not have anything in 'neu'")
        return

    if not debug:
        shutil.move(memberfolder + "/neu/", memberfolder + f"/{date}/.")
    else:
        print("would move:")
        print(memberfolder + "/neu/")
        print(memberfolder + f"/{date}/.")

    ### USER PERMS
    if not debug:
        chown("roboag", "roboag", memberfolder + f"/{date}")
        chown("roboag", "roboag", memberfolder + "/neu")
    else:
        print("would change perms:")
        print(memberfolder + f"/{date}")
        print(memberfolder + "/neu")
        print("to:")
        print("roboag:roboag")

def NewNeuFolder(debug = False):
    for folder in os.listdir(MEMBER_FOLDER_PATH):
        if folder == "_alte_Daten":
            continue
        create_member_neu_folder(folder, debug = debug)

    print("done :-)")

def help():
    print("this script handles the member folders")
    print(" -h: shows this help screen")
    print(" -d: enables debug mode")
    print(" -n: creates a new neu folder for all users")
    print(" -a: creates a new member folder")
    print(" -r: removes a member folder")

args = sys.argv[1:]
if args == []:
    help()
    sys.exit()

Debug = False
Neu = False
add = False
rem = False

for char in args[0][1:]:
    if char == "h":
        help()
        sys.exit()
    if char == "d":
        Debug = True
    if char == "n":
        Neu = True
    if char == "a":
        add = True
    if char == "r":
        rem = True

if add and rem:
    print("error: you can't add and remove at the same time")
    help()
    sys.exit()

if add:
    if not Debug:
        create_member_folder(args[2])
    else:
        print("would create:")
        print(os.path.join(MEMBER_FOLDER_PATH, args[2]))

if rem:
    if not Debug: 
        shutil.rmtree(os.path.join(MEMBER_FOLDER_PATH, args[2]))
    else:
        print("would remove:")
        print(os.path.join(MEMBER_FOLDER_PATH, args[2]))

if Neu:
    NewNeuFolder(debug = Debug)
    sys.exit()
