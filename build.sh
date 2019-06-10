#!/bin/bash

current_dir=`pwd`
cd /e/csgo-ds-experiment/csgo/addons/sourcemod/scripting/
./spcomp.exe "$current_dir/knifestats.sp"
if [ $? -eq 0 ]; then
    mv $current_dir/knifestats.smx ../plugins
fi
cd $current_dir
