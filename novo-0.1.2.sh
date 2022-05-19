#!/bin/bash

# wget https://raw.githubusercontent.com/bitsko/novoconfig/main/novo-0.1.2.sh && chmod +x novo-0.1.2.sh && ./novo-0.1.2.sh

# USE AT YOUR OWN RISK
# STOP YOUR NODE FIRST
IFS= read -r -p "stop your node first.  press ctrl+c to exit or any key to continue" anykey

#turn tx indexing on with "index" as pos. param.
index=0; if [[ "$@" =~ "index" ]]; then index=1; fi

#version of binary
vrs="0.1.2"
tar_gz=novo-"$vrs"-x86_64-linux-gnu.tar.gz
binary=https://github.com/novobitcoin/novobitcoin-release/releases/download/v"$vrs"/"$tar_gz"

old_dir="$HOME/.novo-bitcoin"
new_dir="$HOME/.novo"

if [[ -d "$old_dir" ]]; then
	cp -r "$old_dir" "$new_dir"
fi

if [[ ! -d "$new_dir" ]]; then
        mkdir -p "$new_dir/bin"
fi

wget "$binary" && tar -xzvf "$tar_gz"

cp novo-"$vrs"/bin/novo-cli "$new_dir/bin/novo-cli"
cp novo-"$vrs"/bin/novod "$new_dir/bin/novod"
cp novo-"$vrs"/bin/novo-tx "$new_dir/bin/novo-tx"

rm -r novo-"$vrs"
rm "$tar_gz"

if [[ ! -f "$new_dir/novo.conf" ]]; then
        IFS= read -r -p "enter a username for novod"$'\n>' username
        IFS= read -r -p "enter a rpc password for novod"$'\n>' rpcpassword
        echo "port=8666"$'\n'"rpcport=8665"$'\n'"rpcuser=$username"$'\n'"rpcpassword=$rpcpassword" > "$new_dir/novo.conf"
        if [[ "$index" == 1 ]]; then echo "txindex=1" >> "$new_dir/novo.conf"; fi
fi

echo $'\n'"binaries available in $HOME/.novo/bin"$'\n'
echo "one way to start the node would be to type:"
echo "$HOME/.novo/bin/novod --daemon"
echo $'\n'"check version with:"
echo "$HOME/.novo/bin/novo-cli --version"

