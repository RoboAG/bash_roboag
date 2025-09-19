import os
import shutil
import sys
import pwd
import grp

cwd = os.path.dirname(os.path.abspath(__file__))

users = os.listdir("/home")
configdirectory = cwd + "/../configs"

args = sys.argv[1:]

def chown(name = "roboag", group = "roboag", folder = ""):
    if folder == "":
        sys.exit("error: no folder given")

    userid = pwd.getpwnam(name).pw_uid
    groupid = grp.getgrnam(group).gr_gid
    
    for root, dirs, files in os.walk(folder):
        for name in dirs + files:
            os.chown(os.path.join(root, name), userid, groupid)

def gethelp():
    print("this script is made to install configs to /home/<user>/.config")
    print(" -h: shows this help screen")
    print(" -y: autoconfirm all, usefull for automatic updates")
    print(" -d: enables debug mode")

def InstallConfig(debug = False, NoUser = False):
    print()
    ### GET CONFIG TO INSTALL ###
    config_modules = os.listdir(configdirectory)
    if debug:
        print("DEBUG MODE ENABLED, NO CHANGES ARE MADE")
        print(f"cwd: {cwd}")
        print(f"configdirectory: {configdirectory}")
        print(f"config_modules: {config_modules}")
    echo = ["0: all below"]
    echo += [str(i+ 1) + ": " + module for i, module in enumerate(config_modules)]
    for line in echo:
        print(line)

    configselection = -1
    if NoUser:
        configselection = 0
    else:
        try:
            userinput = input("config to install (default = 0): ")
            print()
            if userinput == "":
                configselection = 0
            else:
                configselection = int(userinput)
        except ValueError as e:
            print("error: " + e.__str__())
            print("Aborting ...")
            sys.exit()
    
    if configselection < 0 or configselection > len(config_modules):
        print("selection out of bounds")
        print("Aborting ...")
        sys.exit()


    ### SAME THING FOR USERS ###
    echo = ["0: all below"]
    echo += [str(i+ 1) + ": " + module for i, module in enumerate(users)]
    for line in echo:
        print(line)

    userselection = -1

    if NoUser:
        userselection = 0
    else:
        try:
            userinput = input("user to install to (default = 0): ")
            print()
            
            if userinput == "":
                userselection = 0
            else:
                userselection = int(userinput)
        except ValueError as e:
            print("error: " + e.__str__())
            print("Aborting ...")
            sys.exit()

    
    if userselection < 0 or userselection > len(users):
        print("selection out of bounds")
        print("Aborting ...")
        sys.exit()


    configs_to_install = []
    print("installing: ")
    if configselection == 0:
        for module in config_modules:
            print(" - " + module)
            configs_to_install.append(module)
    else:
        print(" - " + config_modules[configselection - 1])
        configs_to_install.append(config_modules[configselection - 1])

    users_to_install = []
    print("for: ")
    if userselection == 0:
        for user in users:
            print(" - " + user)
            users_to_install.append(user)
    else:
        print(" - " + users[userselection - 1])
        users_to_install.append(users[userselection - 1])

    if not NoUser:
        if not input("are you sure? y/N: ").strip().lower() in ["yes", "y"]:
            print("Aborting ...")
            sys.exit()

    for user in users_to_install:
        userconfigdir = "/home/"+user+"/.config/"
        for config in configs_to_install:
            if os.path.exists(userconfigdir+config):
                print("removing old config")
            if debug == False:
                if os.path.exists(userconfigdir+config):
                    shutil.rmtree(userconfigdir+config)
                shutil.copytree(configdirectory + "/" +config, userconfigdir+config)
                chown(name = user,group = user ,folder = userconfigdir+config)
            print("copied "+configdirectory+"/"+config+" into "+userconfigdir+config)

    print("finished")

if args == []:
    InstallConfig()
    sys.exit()

if args[0][:2] == "-h":
    gethelp()
    sys.exit()
else:
    flags = args[0][1:]
    NoUser = False
    Debug = False
    for flag in flags:
        if flag == "y":
            NoUser = True
        if flag == "d":
            Debug = True

    InstallConfig(debug=Debug, NoUser=NoUser)
