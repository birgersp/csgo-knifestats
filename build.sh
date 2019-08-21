#!/bin/bash

if [[ -z $CSGO_DS_DIR ]]; then
    echo "Error: Variable CSGO_DS_DIR is unset."
    echo "Use: export CSGO_DS_DIR=(path)"
    echo "Example: export CSGO_DS_DIR=/c/csgo-server"
    exit 1
fi

current_dir=`pwd`
cd $CSGO_DS_DIR/csgo/addons/sourcemod/scripting/
./spcomp.exe "$current_dir/knifestats.sp"
if [ $? -eq 0 ]; then
    mv $current_dir/knifestats.smx ../plugins
fi
cd $current_dir
