#!/bin/bash

# compile the latest version of novo node; for ubuntu, debian and manjaro on 64 bit and ARM processors
# wget -N https://raw.githubusercontent.com/bitsko/novoconfig/main/novo_node_compile.sh && chmod +x novo_node_compile.sh && ./novo_node_compile.sh

script_exit(){ unset novoUsr novoRpc novoCpu novoAdr novoDir novoCnf novoVer novoTgz novoGit \
	novo_OS novoSrc novoNum novoPrc archos_array deb_os_array armcpu_array x86cpu_array pkg_Err; }
pkg_Err(){ if [[ "$?" != 0 ]]; then echo "package update failed"; exit 1; fi; }

declare -a deb_os_array=( debian ubuntu raspbian linuxmint pop )
declare -a archos_array=( manjaro-arm manjaro endeavouros arch )
declare -a armcpu_array=( aarch64 aarch64_be armv8b armv8l armv6l )
declare -a x86cpu_array=( i686 x86_64 )
novo_OS=$(source /etc/os-release; echo "$ID")
if [[ "${deb_os_array[*]}" =~ "$novo_OS" ]]; then
	sudo apt update
	sudo apt -y upgrade
	declare -a dpkg_pkg_array_=( build-essential libtool autotools-dev pkg-config \
	bsdmainutils python3 libevent-dev libboost-system-dev libboost-filesystem-dev \
	libboost-chrono-dev libboost-program-options-dev libboost-test-dev automake \
	libboost-thread-dev libsqlite3-dev libqrencode-dev libdb-dev libdb++-dev \
	libssl-dev miniupnpc bc curl jq wget )
	while read -r line; do
        	if ! dpkg -s "$line" &> /dev/null; then
			dpkg_to_install+=( "$line" )
		fi
       	done <<<$(printf '%s\n' "${dpkg_pkg_array_[@]}")
	unset dpkg_pkg_array_
	if [[ -n "${dpkg_to_install[*]}" ]]; then
                sudo apt -y install ${dpkg_to_install[*]}
                pkg_Err
              	unset dpkg_to_install
        fi
	if [[ "{armcpu_array[*]}" =~ $(uname -m) ]]; then
		if ! dpkg -s g++-arm-linux-gnueabihf &> /dev/null; then
			sudo apt -y install g++-arm-linux-gnueabihf
			pkg_Err
		fi
	fi
elif [[ "{archos_array[*]}" =~ "$novo_OS" ]]; then
	sudo pacman -Syu
	declare -a arch_pkg_array_=( boost boost-libs libevent libnatpmp \
	binutils libtool m4 make systemd python automake autoconf zeromq \
	sqlite qrencode nano bc bison fakeroot file findutils flex gawk \
	gcc gettext grep groff patch pkgconf sed texinfo which miniupnpc \
	gzip curl jq wget )
	while read -r line; do
        	if ! pacman -Qi "$line" &> /dev/null; then
			arch_to_install+=( "$line" )
			pkg_Err
		fi
	done <<<$(printf '%s\n' "${arch_pkg_array_[@]}")
	unset arch_pkg_array_
        if [[ -n "${arch_to_install[*]}" ]]; then
       	        sudo pacman --noconfirm -Sy ${arch_to_install[*]}
       		pkg_Err
                unset arch_to_install
       	fi
	if [[ "{armcpu_array[*]}" =~ $(uname -m ) ]]; then
		if ! pacman -Qi arm-none-eabi-binutils &> /dev/null; then
			sudo pacman --noconfirm -Sy arm-none-eabi-binutils
			pkg_Err
		fi
                if ! pacman -Qi arm-none-eabi-gcc &> /dev/null;	then
			sudo pacman --noconfirm -Sy arm-none-eabi-gcc
			pkg_Err
		fi
	fi
else
	echo "$(source /etc/os-release; echo "$ID") unsupported"
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
cd "$novoSrc" || echo "unable to cd to $novoSrc"
./autogen.sh
if [[ "{armcpu_array[*]}" =~ $(uname -m) ]]; then
	CONFIG_SITE="$PWD"/depends/arm-linux-gnueabihf/share/config.site \
	./configure --without-gui --enable-reduce-exports LDFLAGS=-static-libstdc++
elif [[ "{x86cpu_array[*]}" =~ $(uname -m) ]]; then
	./configure --without-gui
fi
novoPrc=$(echo "$(nproc) - 1" | bc)
if [[ "$novoPrc" == 0 ]]; then novoPrc="1"; fi
make -j "$novoPrc"
if [[ ! -d "$novoBin" ]]; then mkdir "$novoBin"; fi
cp src/novod "$novoBin"/novod && strip "$novoBin"/novod
cp src/novo-cli "$novoBin"/novo-cli && strip "$novoBin"/novo-cli
cp src/novo-tx "$novoBin"/novo-tx && strip "$novoBin"/novo-tx
echo "binaries available in $novoBin"
if [[ ! -f "$novoCnf" ]]; then
	# transaction indexing enabled by default
	IFS=' ' read -r -p "enter a novod username"$'\n>' novoUsr
	IFS=' ' read -r -p "enter a novod rpc password"$'\n>' novoRpc
	echo \
	"port=8666"$'\n'\
	"rpcport=8665"$'\n'\
	"rpcuser=$novoUsr"$'\n'\
	"rpcpassword=$novoRpc"$'\n'\
	"gen=1"$'\n'\
	"txindex=1"$'\n'\
	"maxmempool=1600" \
	> "$novoCnf"
fi
script_exit
unset -f script_exit
