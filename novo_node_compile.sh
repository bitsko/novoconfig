#!/bin/bash

# wget -N https://raw.githubusercontent.com/bitsko/novoconfig/main/novo_node_compile.sh && chmod +x novo_node_compile.sh && ./novo_node_compile.sh

script_exit(){ unset novoUsr novoRpc novoCpu novoAdr novoDir novoCnf novoVer novoTgz novoGit novo_OS novoSrc novoNum; }

if [[ $(uname -m) == "aarch64" ]] || [[ $(uname -m) == "aarch64_be" ]] || \
	[[ $(uname -m) == "armv8b" ]] || [[ $(uname -m) == "armv8l" ]] || \
	[[ $(uname -m) == "i686" ]] || [[ $(uname -m) == "x86_64" ]]; then

	novo_OS=$(source /etc/os-release; echo "$ID")
	if [[ "$novo_OS" == "debian" ]] || [[ "$novo_OS" == "ubuntu" ]]; then
		sudo apt update
		sudo apt -y upgrade
		if ! dpkg -s curl &> /dev/null;	then sudo apt install curl; fi
		if ! dpkg -s jq &> /dev/null; then sudo apt install jq;	fi
	elif [[ "$novo_OS" == "manjaro-arm" ]] || [[ "$novo_OS" == "manjaro" ]]; then
		sudo pacman -Syu
        	if ! pacman -Qs curl &> /dev/null; then sudo pacman --noconfirm -Syu curl; fi
        	if ! pacman -Qs jq &> /dev/null; then sudo pacman --noconfirm -Syu jq; fi
	else
		echo "OS unsupported; ask @bitsko in the telegram chat to add your 64 bit Linux OS"
		script_exit
		unset -f script_exit
		exit 1
	fi

	novoDir="$HOME/.novo"
	novoBin="$novoDir/bin"
	novoCnf="$novoDir/novo.conf"
	novoVer="$(curl -s https://api.github.com/repos/novoworks/novo/releases/latest | jq .tag_name | sed 's/"//g' )"
	novoTgz="$novoVer".tar.gz
	novoGit="https://github.com/novoworks/novo/archive/refs/tags/$novoTgz"
	novoNum="${novoVer//v/}"
#	"$(sed 's/v//g'<<<"$novoVer")"
	novoSrc="$PWD/novo-$novoNum"
	if [[ ! -d "$novoDir" ]]; then
		mkdir "$novoDir"
	elif [[ -d "$novoDir" ]]; then
		echo $'\n'"backing up existing novo directory"$'\n'
		IFS= read -r -p "stop your node first if running. press enter to continue"
		cp -r "$novoDir" "$HOME"/novo."$EPOCHSECONDS".backup
		echo "existing .novo folder backed up to: $HOME/novo.$EPOCHSECONDS.backup"
	fi

	wget -N "$novoGit"
	tar -xf "$novoTgz"

	if [[ "$novo_OS" == "debian" ]] || [[ "$novo_OS" == "ubuntu" ]]; then
		sudo apt update
		declare -a dpkg_pkg_array_=( build-essential libtool autotools-dev pkg-config \
		bsdmainutils python3 libevent-dev libboost-system-dev libboost-filesystem-dev \
		libboost-chrono-dev libboost-program-options-dev libboost-test-dev automake \
		libboost-thread-dev libsqlite3-dev libqrencode-dev g++-arm-linux-gnueabihf \
		libdb-dev libdb++-dev libssl-dev miniupnpc screen bc )
		while read -r line; do
	        if ! dpkg -s "$line" &> /dev/null
                then sudo apt -y install "$line"
	        fi
		done <<<"$(printf '%s\n' "${dpkg_pkg_array_[@]}")"
		unset dpkg_pkg_array_

	elif [[ "$novo_OS" == "manjaro-arm" ]] || [[ "$novo_OS" == "manjaro" ]]; then
		sudo pacman -Syu
		declare -a arch_pkg_array_=( boost boost-libs libevent libnatpmp \
		binutils libtool m4 make systemd python automake autoconf zeromq \
		sqlite qrencode arm-none-eabi-binutils arm-none-eabi-gcc nano bc \
		bison fakeroot file findutils flex gawk gcc gettext grep groff \
		patch pkgconf sed texinfo which miniupnpc screen gzip )
		while read -r line; do
	        	if ! pacman -Qs "$line" &> /dev/null
	                	then sudo pacman --noconfirm -Syu "$line"
		        fi
		done <<<"$(printf '%s\n' "${arch_pkg_array_[@]}")"
		unset arch_pkg_array_
	fi

	cd "$novoSrc" || echo "unable to cd to $novoSrc"
	./autogen.sh
	if [[ $(uname -m) == "aarch64" ]] || [[ $(uname -m) == "aarch64_be" ]] || \
        	[[ $(uname -m) == "armv8b" ]] || [[ $(uname -m) == "armv8l" ]]; then
		CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site \
		./configure --without-gui --enable-reduce-exports LDFLAGS=-static-libstdc++
        elif [[ $(uname -m) == "i686" ]] || [[ $(uname -m) == "x86_64" ]]; then
		./configure --without-gui
	fi
	make -j "$(echo "$(nproc) - 1" | bc)"
	if [[ ! -d "$novoBin" ]]; then mkdir "$novoBin"; fi
	cp src/novod "$novoBin"/novod && strip "$novoBin"/novod
	cp src/novo-cli "$novoBin"/novo-cli && strip "$novoBin"/novo-cli
	cp src/novo-tx "$novoBin"/novo-cli && strip "$novoBin"/novo-tx
	echo "binaries available in $novoBin"
	if [[ ! -f "$novoCnf" ]]; then
		IFS=' ' read -r -p "enter a novod username"$'\n>' novoUsr
		IFS=' ' read -r -p "enter a novod rpc password"$'\n>' novoRpc
		echo "port=8666"$'\n'"rpcport=8665"$'\n'"rpcuser=$novoUsr"$'\n'\
		"rpcpassword=$novoRpc"$'\n'"gen=1"$'\n'"txindex=1" > "$novoCnf"

	fi

script_exit
unset -f script_exit

else
	echo "CPU architecture unsupported by this script. Is it 64 bit?"
	script_exit
	unset -f script_exit
	exit 1
fi
