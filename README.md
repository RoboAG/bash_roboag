# bash_roboag
scripts for setup, configuration und daily tasks within RoboAG

## setup
create workspace directory
```
mkdir -p ~/workspace
cd ~/workspace
```

download scripts
```
wget -nv https://raw.githubusercontent.com/peterweissig/bash_roboag/master/checkout.sh
bash ./checkout.sh
```

checkout additionals repositories (e.g. robolib)
```
git_clone_robo_lib
git_clone_robo_pololu
```

## installation
For install instructions see [doc/install](doc/install.md).
