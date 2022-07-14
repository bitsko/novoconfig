#!/bin/bash

# compile the latest version of novo node

# wget -N https://raw.githubusercontent.com/bitsko/novoconfig/main/novo_node_compile.sh && chmod +x novo_node_compile.sh && ./novo_node_compile.sh
# on BSD to run the script use "bash novo_node_compile.sh"
pkg_Err(){ if [[ "$?" != 0 ]]; then echo $'\n'"package update failed"; exit 1; fi; }
script_exit(){ unset novoUsr novoRpc novoCpu novoAdr novoDir novoCnf novoVer novoTgz novoGit \
	novo_OS novoSrc novoNum archos_array deb_os_array armcpu_array x86cpu_array \
	bsdpkg_array redhat_array cpu_type pkg_Err novoBsd; }

# dependency installation script
cpu_type="$(uname -m)"
novoBsd=0
declare -a bsdpkg_array=( freebsd )
declare -a redhat_array=( fedora )
declare -a deb_os_array=( debian ubuntu raspbian linuxmint pop )
declare -a archos_array=( manjaro-arm manjaro endeavouros arch )
declare -a armcpu_array=( aarch64 aarch64_be armv8b armv8l armv7l )
declare -a x86cpu_array=( i686 x86_64 i386 )

novo_OS=$(source /etc/os-release; echo "$ID")
if [[ "${deb_os_array[*]}" =~ "$novo_OS" ]]; then
	sudo apt update
	sudo apt -y upgrade
	declare -a dpkg_pkg_array_=( build-essential libtool autotools-dev pkg-config \
		bsdmainutils python3 libevent-dev libboost-system-dev libboost-filesystem-dev \
		libboost-chrono-dev libboost-program-options-dev libboost-test-dev automake \
		libboost-thread-dev libsqlite3-dev libqrencode-dev libdb-dev libdb++-dev \
		libssl-dev miniupnpc bc curl jq wget libzmq3-dev )
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
	if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
		if ! dpkg -s g++ &> /dev/null; then
			sudo apt -y install g++-arm-linux-gnueabihf
			pkg_Err
		fi
	fi
elif [[ "${archos_array[*]}" =~ "$novo_OS" ]]; then
	sudo pacman -Syu
	declare -a arch_pkg_array_=( boost boost-libs libevent libnatpmp \
		binutils libtool m4 make automake autoconf zeromq gzip curl\
		sqlite qrencode nano fakeroot gcc grep pkgconf sed miniupnpc \
		jq wget bc )
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
	if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
		if ! pacman -Qi arm-none-eabi-binutils &> /dev/null; then
			sudo pacman --noconfirm -Sy arm-none-eabi-binutils
			pkg_Err
		fi
                if ! pacman -Qi arm-none-eabi-gcc &> /dev/null;	then
			sudo pacman --noconfirm -Sy arm-none-eabi-gcc
			pkg_Err
		fi
	fi
elif [[ "${bsdpkg_array[*]}" =~ "$novo_OS" ]]; then
	novoBsd=1
	pkg upgrade -y
	declare -a bsd__pkg_array_=( boost-all libevent gcc autotools \
			libqrencode octave-forge-zeromq libnpupnp \
			nano fakeroot pkgconf miniupnpc gzip curl \
			jq wget db5 libressl gmake )
	while read -r line; do 
		if ! type "$line" >/dev/null; then
			pkg_to_install_+=( "$line" )
		fi
	done <<<$(printf '%s\n' "${bsd__pkg_array_[@]}")
	unset bsd__pkg_array_
	if [[ -n "${pkg_to_install_[*]}" ]]; then
		pkg install -y ${pkg_to_install_[*]}
		pkg_Err
	fi
else
	echo "$novo_OS unsupported"
	script_exit
	unset -f script_exit
	exit 1
fi
# end dependency installation script
# file and path variables
novoDir="$HOME/.novo"
novoBin="$novoDir/bin"
novoCnf="$novoDir/novo.conf"
novoVer="$(curl -s https://api.github.com/repos/novoworks/novo/releases/latest | jq .tag_name | sed 's/"//g' )"
novoTgz="$novoVer".tar.gz
novoGit="https://github.com/novoworks/novo/archive/refs/tags/$novoTgz"
novoNum="${novoVer//v/}"
novoSrc="$PWD/novo-$novoNum"

#make directories, backup folders
if [[ ! -d "$novoDir" ]]; then
	mkdir "$novoDir"
elif [[ -d "$novoDir" ]]; then
	echo $'\n'"backing up existing novo directory"$'\n'
	IFS= read -r -p "stop your node first if running. press enter to continue"
	cp -r "$novoDir" "$HOME"/novo."$EPOCHSECONDS".backup
	echo "existing .novo folder backed up to: $HOME/novo.$EPOCHSECONDS.backup"
fi

# download
wget -N "$novoGit"

# extract
tar -xf "$novoTgz"
cd "$novoSrc" || echo "unable to cd to $novoSrc"

# autogen
./autogen.sh
# configure with arm specific instructions
if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]] && [[ "$novoBSD" == 0 ]]; then
	CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site \
	./configure --without-gui --enable-reduce-exports LDFLAGS=-static-libstdc++
elif [[ "${x86cpu_array[*]}" =~ "$cpu_type" ]] && [[ "$novoBSD" == 0 ]]; then
	./configure --without-gui
elif [[ "$novoBSD" == 1 ]]; then
	./configure --without-gui --disable-dependency-tracking --disable-hardening MAKE="gmake" \
      CFLAGS="-I/usr/local/include" CXXFLAGS="-I/usr/local/include -I/usr/local/include/db5" \
      LDFLAGS="-L/usr/local/lib -L/usr/local/lib/db5"
fi

# make
if [[ "$novoBsd" == 1 ]]; then
	gmake
else
	novoPrc=$(echo "$(nproc) - 1" | bc)
	if [[ "$novoPrc" == 0 ]]; then novoPrc="1"; fi
	make -j "$novoPrc"
	unset novoPrc
fi
# if [[ "$?" != 0 ]]; then echo $'\n'"make package failed"; exit 1; fi

if [[ ! -d "$novoBin" ]]; then mkdir "$novoBin"; fi

# copies and strips the executables, placing them in .novo/bin
cp src/novod "$novoBin"/novod && strip "$novoBin"/novod
cp src/novo-cli "$novoBin"/novo-cli && strip "$novoBin"/novo-cli
cp src/novo-tx "$novoBin"/novo-tx && strip "$novoBin"/novo-tx

# if successful, print location of binaries to terminal
if [[ "$?" == 0 ]]; then
	echo $'\n'"binaries available in $novoBin"$'\n'
	ls "$novoBin"
fi

# creates the node configuration file
if [[ ! -f "$novoCnf" ]]; then
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
