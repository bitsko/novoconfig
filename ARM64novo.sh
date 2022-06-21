#!/bin/bash


#there is no source code for this script to work with
#untested 
#missing something, doesnt work, mining also not working


#need to fill these in
username=
rpcpassword=
threads=
miningAddress=

echo "raspi 64 bit debian ubuntu manjaro novo compile script"

novoDir="$HOME/.novo"
novoBin="$HOME/.novo/bin"
minerConf="$novoBin/cfg.json"
novoConf="$HOME/.novo/novo.conf"

#sourceDir=novo
# https://github.com/novoworks/novo-release/releases/
#source=https://github.com/idkbro/"$sourceDir"
#git clone "$source"
#cd "$sourceDir"

#os_release_ID=$(source /etc/os-release; echo $ID)

#if [[ "$os_release_ID" == "debian" ]] || [[ "$os_release_ID" == "ubuntu" ]]; then
sudo apt update
sudo apt upgrade -y
sudo apt-get install \
	build-essential libtool autotools-dev automake pkg-config \
	bsdmainutils python3 libevent-dev libboost-system-dev libboost-filesystem-dev \
	libboost-chrono-dev libboost-program-options-dev libboost-test-dev \
	libboost-thread-dev libsqlite3-dev libqrencode-dev g++-arm-linux-gnueabihf \
	curl libdb-dev libdb++-dev libssl-dev miniupnpc screen

#elif [[ "$os_release_ID" == "manjaro-arm" ]]; then
sudo pacman -Syu
sudo pacman -S boost boost-libs libevent libnatpmp zeromq autoconf automake \
	binutils libtool m4 make systemd python \
	sqlite qrencode arm-none-eabi-binutils arm-none-eabi-gcc \
	bison fakeroot file findutils flex gawk gcc gettext grep groff gzip \
	patch pkgconf sed texinfo which miniupnpc screen nano 
#fi

./autogen.sh

CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site \
	./configure --without-gui --enable-reduce-exports LDFLAGS=-static-libstdc++

# if [[ "$os_release_ID" == "debian" ]] || [[ "$os_release_ID" == "ubuntu" ]]; then

make 

#	echo "update() { sudo apt update && sudo apt upgrade -y; }" >> ~/.bash_aliases
# elif [[ "$os_release_ID" == "manjaro" ]]; then
#	make -j 2
#	echo "update() { sudo pacman -Syu ; }" >> ~/.bashrc
# fi

# echo "nwal(){ \$HOME/.novo/bin/novo-cli getwalletinfo; }" >> ~/.bashrc
# echo "ninfo(){ \$HOME/.novo/bin/novo-cli getinfo; }" >> ~/.bashrc
# echo "nhelp(){ \$HOME/.novo/bin/novo-cli help; }" >> ~/.bashrc
# echo "nstart(){ \$HOME/.novo/bin/novo.sh ; }" >> ~/.bashrc
# echo "ncli(){ \$HOME/.novo/bin/novo-cli \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9; }" >> ~/.bashrc
# echo "source ~/.bashrc or restart to use aliases such as nwal and ncli"

if [[ ! -d "$HOME/.novo" ]]; then
	mkdir "$HOME/.novo"
fi
if [[ ! -d "$HOME/.novo/bin" ]]; then 
	mkdir "$HOME/.novo/bin"
	cp novod "$novoBin"/novod
	cp novo-cli "$novoBin"/novo-cli
	strip "$novoBin"/novod
	strip "$novoBin"/novo-cli
fi	

echo "port=8666"$'\n'"rpcport=8665"$'\n'"rpcuser=$username"$'\n'\
	"rpcpassword=$rpcpassword"$'\n'"gen=1" > "$novoConf"

echo "{"$'\n'"  \"url\" : \"http://127.0.0.1:8665\","$'\n'"  \"user\" : \"$username\","$'\n'\
                " \"pass\" : \"$rpcpassword\","$'\n'"  \"algo\" : \"sha256dt\","$'\n'\
                " \"threads\" : \"$threads\","$'\n'"  \"coinbase-addr\": \"$miningAddress\""$'\n'"}" \
                > "$minerConf"
