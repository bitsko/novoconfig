#!/bin/bash

#missing something, doesnt work, mining also not working

echo "raspi 64 bit debian ubuntu manjaro novo compile script"

IFS=' ' read -r -p "enter a novod username" novoUsr
IFS=' ' read -r -p "enter a novod rpc password" novoRpc
IFS=' ' read -r -p "how many cpu cores to mine with?" novoCpu
IFS=' ' read -r -p "what address would you like to mine to?" novoAdr

novoDir="$HOME/.novo"
novoBin="$novoDir/bin"
novoMnr="$novoBin/cfg.json"
novoCnf="$novoDir/novo.conf"
novoVer="0.2.0"
novoSrc="$HOME/novo_src_v$novoVer"
novoTgz=v"$novoVer".tar.gz
novoGit="https://github.com/novoworks/novo/archive/refs/tags/$novoTgz"

wget "$novoGit"
tar -xf "$novoTgz" -C "$novoSrc"

novo_OS=$(source /etc/os-release; echo $ID)

if [[ "$novo_OS" == "debian" ]] || [[ "$novo_OS" == "ubuntu" ]]; then

sudo apt update
sudo apt upgrade -y
sudo apt -y install \
	build-essential libtool autotools-dev automake pkg-config \
	bsdmainutils python3 libevent-dev libboost-system-dev libboost-filesystem-dev \
	libboost-chrono-dev libboost-program-options-dev libboost-test-dev \
	libboost-thread-dev libsqlite3-dev libqrencode-dev g++-arm-linux-gnueabihf \
	curl libdb-dev libdb++-dev libssl-dev miniupnpc screen bc

elif [[ "$novo_OS" == "manjaro-arm" ]]; then
sudo pacman -Syu
sudo pacman -S boost boost-libs libevent libnatpmp zeromq autoconf automake \
	binutils libtool m4 make systemd python \
	sqlite qrencode arm-none-eabi-binutils arm-none-eabi-gcc \
	bison fakeroot file findutils flex gawk gcc gettext grep groff gzip \
	patch pkgconf sed texinfo which miniupnpc screen nano bc
fi
cd "$novoSrc"
./autogen.sh

CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site \
	"$novoSrc"/configure --without-gui --enable-reduce-exports LDFLAGS=-static-libstdc++

make -j $(echo "$(nproc) - 1" | bc)

if [[ ! -d "$novoDir" ]]; then
	mkdir "$novoDir"
fi

if [[ ! -d "$novoBin" ]]; then 
	mkdir "$novoBin"
fi

cp novod "$novoBin"/novod
cp novo-cli "$novoBin"/novo-cli
strip "$novoBin"/novod
strip "$novoBin"/novo-cli

echo "port=8666"$'\n'"rpcport=8665"$'\n'"rpcuser=$novoUsr"$'\n'\
	"rpcpassword=$novoRpc"$'\n'"gen=1" > "$novoCnf"

echo "{"$'\n'"  \"url\" : \"http://127.0.0.1:8665\","$'\n'"  \"user\" : \"$novoUsr\","$'\n'\
                " \"pass\" : \"$novoRpc\","$'\n'"  \"algo\" : \"sha256dt\","$'\n'\
                " \"threads\" : \"$novoCpu\","$'\n'"  \"coinbase-addr\": \"$novoAdr\""$'\n'"}" \
                > "$novoCnf"

unset novoUsr novoRpc novoCpu novoAdr novoDir novoMnr novoCnf novoVer novoSrc novoTgz novoGit novo_OS	
