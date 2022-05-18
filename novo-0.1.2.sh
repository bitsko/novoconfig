#!/bin/bash

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

if [[ ! -d "$new_dir" ]]; then
        mkdir "$new_dir"
fi

if [[ -d "$old_dir" ]]; then
        cp "$old_dir/novo.conf" "$new_dir/novo.conf"
        cp "$old_dir/wallet.dat" "$new_dir/wallet.dat"
        if [[ -f "$old_dir/bin/cfg.json" ]]; then
                cp "$old_dir/bin/cfg.json" "$new_dir/bin/cfg.json"
        fi
else
        mkdir -p "$HOME/.novo/bin"
fi

wget "$binary" && tar -xzvf "$tar_gz"
cp "$PWD"/novo-"$vrs"/bin/novo-cli "$HOME/.novo/bin/novo-cli"
cp "$PWD"/novo-"$vrs"/bin/novod "$HOME/.novo/bin/novod"
cp "$PWD"/novo-"$vrs"/bin/novo-tx "$HOME/.novo/bin/novo-tx"

if [[ ! -f "$new_dir/novo.conf" ]]; then
        IFS= read -r -p "enter a username for novod"$'\n>' username
        IFS= read -r -p "enter a rpc password for novod"$'\n>' rpcpassword
        echo "port=8666"$'\n'"rpcport=8665"$'\n'"rpcuser=$username"$'\n'"rpcpassword=$rpcpassword" > "$new_dir/novo.conf"
        if [[ "$index" == 1 ]]; then echo "txindex=1" >> "$new_dir/novo.conf"; fi
fi
echo "binaries available in $HOME/.novo/bin"
echo "one way to start the node would be to type"
echo "$HOME/.novo/bin/novod --daemon"
echo "check version with"
echo "$HOME/.novo/bin/novo-cli --version"
