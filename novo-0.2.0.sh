#!/bin/bash

# wget https://raw.githubusercontent.com/bitsko/novoconfig/main/novo-0.2.0.sh && chmod +x novo-0.2.0.sh && ./novo-0.2.0.sh

# USE AT YOUR OWN RISK
# STOP YOUR NODE FIRST
IFS= read -r -p "stop your node first.  press ctrl+c to exit or any key to continue" anykey

#turn tx indexing on with "index" as pos. param.
index=0; if [[ "$@" =~ "index" ]]; then index=1; fi

#version of binary
novo_vrs="0.2.0"
tar_gz=novo-"$novo_vrs"-x86_64-linux-gnu.tar.gz
nbinary=https://github.com/novoworks/novo/releases/download/v"$novo_vrs"/"$tar_gz"


old_dir="$HOME/.novo-bitcoin"
new_dir="$HOME/.novo"

# check if folder already exists and if so back it up
if [[ -d "$new_dir" ]]; then
        cp -r "$new_dir" "$new_dir"."$EPOCHSECONDS".backup
	echo $'\n'"***"$'\n'"backing up existing novo install to $new_dir.$EPOCHSECONDS.backup"$'\n'"***"$'\n'
fi

# check if early version exists and copy over the blockchain and files
if [[ -d "$old_dir" ]]; then
	cp -r "$old_dir" "$new_dir"
fi

# check if the new directory does not exist and if so make it
if [[ ! -d "$new_dir" ]]; then
        mkdir -p "$new_dir/bin"
fi

# download the binary
wget "$nbinary" && tar -xzvf "$tar_gz"

# copy it over to a folder within the novo folder
cp novo-"$novo_vrs"/bin/novo-cli "$new_dir/bin/novo-cli"
cp novo-"$novo_vrs"/bin/novod "$new_dir/bin/novod"
cp novo-"$novo_vrs"/bin/novo-tx "$new_dir/bin/novo-tx"

# remove the archive
# rm -r novo-"$novo_vrs"
# rm "$tar_gz"

# if a configuration file for the node does not exist, make one
if [[ ! -f "$new_dir/novo.conf" ]]; then
        IFS= read -r -p "enter a username for novod"$'\n>' username
        IFS= read -r -p "enter a rpc password for novod"$'\n>' rpcpassword
        echo "port=8666"$'\n'"rpcport=8665"$'\n'"rpcuser=$username"$'\n'"rpcpassword=$rpcpassword"\
	$'\n'"maxmempool=1600"> "$new_dir/novo.conf"
        if [[ "$index" == 1 ]]; then echo "txindex=1" >> "$new_dir/novo.conf"; fi
fi

# if the mempool settings aren't a part of the config file (required for 0.2.0), add them
if [[ -z $(grep maxmempool "$new_dir/novo.conf") ]]; then
	echo "maxmempool=1600" >> "$new_dir/novo.conf"
fi	

echo $'\n'"binaries available in $HOME/.novo/bin"$'\n'
echo "one way to start the node would be to type:"
echo "$HOME/.novo/bin/novod --daemon"
echo $'\n'"check version with:"
echo "$HOME/.novo/bin/novo-cli --version"

unset novo_vrs
unset tar_gz
unset nbinary
unset new_dir
unset old_dir
