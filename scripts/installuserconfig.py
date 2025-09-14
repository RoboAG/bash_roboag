import os
import sys

cwd = os.path.dirname(os.path.abspath(__file__))

users = os.listdir("/home")
configdirectory = cwd + "/../configs"

def GetConfigToInstall(debug = False):
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

    try:
        print()
        userinput = input("config to install (default = 0): ")
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

    try:
        print()
        userinput = input("config to install (default = 0): ")
        
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


    print("installing: ")
    if configselection == 0:
        for module in config_modules:
            print(" - " + module)
    else:
        print(" - " + config_modules[configselection - 1])

    print("for: ")
    if userselection == 0:
        for user in users:
            print(" - " + user)
    else:
        print(" - " + users[userselection - 1])

GetConfigToInstall()


