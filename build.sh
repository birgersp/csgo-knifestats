#!/bin/sh

if [ -z $CSGO_DS_DIR ]; then
    echo "Error: Variable CSGO_DS_DIR is unset."
    echo "Use: export CSGO_DS_DIR=(path)"
    echo "Example: export CSGO_DS_DIR=/c/csgo-server"
    exit 1
fi

script_name=knifestats

$CSGO_DS_DIR/csgo/addons/sourcemod/scripting/spcomp "$script_name.sp"
if [ $? -eq 0 ]; then
    cp -v $script_name.smx $CSGO_DS_DIR/csgo/addons/sourcemod/plugins
fi
