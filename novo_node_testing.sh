#!/usr/bin/env bash

# compile the latest version of novo node

# wget -N https://raw.githubusercontent.com/bitsko/novoconfig/main/novo_node_compile.sh && chmod +x novo_node_compile.sh && ./novo_node_compile.sh

keep_clean(){ if [[ "$frshDir" == 1 ]]; then rm -r "$novoDir" "$novoTgz"; fi; }
# pkg_Err(){ if [[ "$?" != 0 ]]; then echo $'\n'"package update failed"; exit 1; fi; }
debug_location(){
	if [[ "$?" != 0 ]]; then
		echo $'\n\n'"$debug_step has failed!"$'\n\n'
		keep_clean
		script_exit
		exit 1
	fi; }
script_exit(){ unset novoUsr novoRpc novoCpu novoAdr novoDir novoCnf novoVer novoTgz novoGit \
	novo_OS novoSrc novoNum archos_array deb_os_array armcpu_array x86cpu_array \
	bsdpkg_array redhat_array cpu_type pkg_Err uname_OS novoBsd novoPrc debug_step \
	keep_clean; }

# dependency installation script
debug_step="package installation"

declare -a bsdpkg_array=( freebsd OpenBSD )
declare -a redhat_array=( fedora )
declare -a deb_os_array=( debian ubuntu raspbian linuxmint pop )
declare -a archos_array=( manjaro-arm manjaro endeavouros arch )
declare -a armcpu_array=( aarch64 aarch64_be armv8b armv8l armv7l )
declare -a x86cpu_array=( i686 x86_64 i386 ) # amd64

novoBsd=0
cpu_type="$(uname -m)"
uname_OS="$(uname -s)"
novo_OS=$(if [[ -f /etc/os-release ]]; then source /etc/os-release; echo "$ID"; fi)
if [[ -z "$novo_OS" ]]; then novo_OS="$uname_OS"; fi
if [[ "$novo_OS" == *"BSD" ]]; then novoBsd=2; fi
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
                debug_location
		# pkg_Err
              	unset dpkg_to_install
        fi
	if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
		if ! dpkg -s g++ &> /dev/null; then
			sudo apt -y install g++-arm-linux-gnueabihf
			debug_location 
			# pkg_Err
		fi
	fi
elif [[ "${archos_array[*]}" =~ "$novo_OS" ]]; then
	sudo pacman -Syu
	declare -a arch_pkg_array_=( boost boost-libs libevent libnatpmp binutils libtool m4 make \
		automake autoconf zeromq gzip curl sqlite qrencode nano fakeroot gcc grep pkgconf \
		sed miniupnpc jq wget bc )
	while read -r line; do
        	if ! pacman -Qi "$line" &> /dev/null; then
			arch_to_install+=( "$line" )
			debug_location
			# pkg_Err
		fi
	done <<<$(printf '%s\n' "${arch_pkg_array_[@]}")
	unset arch_pkg_array_
        if [[ -n "${arch_to_install[*]}" ]]; then
       	        sudo pacman --noconfirm -Sy ${arch_to_install[*]}
       		debug_location
		# pkg_Err
                unset arch_to_install
       	fi
	if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
		if ! pacman -Qi arm-none-eabi-binutils &> /dev/null; then
			sudo pacman --noconfirm -Sy arm-none-eabi-binutils
			debug_location
			# pkg_Err
		fi
                if ! pacman -Qi arm-none-eabi-gcc &> /dev/null;	then
			sudo pacman --noconfirm -Sy arm-none-eabi-gcc
			debug_location
			# pkg_Err
		fi
	fi
elif [[ "${bsdpkg_array[*]}" =~ "$novo_OS" ]]; then
	if [[ "$novoBsd" == 2 ]]; then
		declare -a bsd__pkg_array_=(  libevent libqrencode pkgconf miniupnpc jq \
			curl wget gmake python-3.9.13 sqlite3 gcc-11.2.0p2 clang boost nano \
			zeromq openssl libtool-2.4.2p2 autoconf-2.71 automake-1.16.3 g++-11.2.0p2 \
			llvm )
	else
		novoBsd=1
		pkg upgrade -y
		declare -a bsd__pkg_array_=( boost-all libevent autotools libqrencode curl \
			octave-forge-zeromq libnpupnp nano fakeroot pkgconf miniupnpc gzip \
			jq wget db5 libressl gmake python3 sqlite3 binutils gcc clang )
	fi
	while read -r line; do 
		if ! command -v "$line" >/dev/null; then
			pkg_to_install_+=( "$line" )
		fi
	done <<<$(printf '%s\n' "${bsd__pkg_array_[@]}")
	unset bsd__pkg_array_
	if [[ -n "${pkg_to_install_[*]}" ]]; then
		if [[ "$novoBsd" == 1 ]]; then
			pkg install -y ${pkg_to_install_[*]}
			debug_location
			# pkg_Err
		elif [[ "$novoBsd" == 2 ]]; then
			pkg_add ${pkg_to_install_[*]}
			debug_location
			# pkg_Err
		fi
	fi
else
	echo "$novo_OS unsupported"
	script_exit; unset -f script_exit
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
frshDir=0

#make directories, backup folders
if [[ ! -d "$novoDir" ]]; then
	mkdir "$novoDir"
	frshDir=1
elif [[ -d "$novoDir" ]]; then
	echo $'\n'"backing up existing novo directory"$'\n'
	IFS= read -r -p "stop your node first if running. press enter to continue"
	cp -r "$novoDir" "$HOME"/novo."$EPOCHSECONDS".backup
	echo "existing .novo folder backed up to: $HOME/novo.$EPOCHSECONDS.backup"
fi

# download
debug_step="wget $novoGit"
if [[ ! -f "$novoTgz" ]]; then
	wget "$novoGit"
else
	echo "$novoTgz already downloaded"
fi
debug_location
# if [[ "$?" != 0 ]]; then echo $'\n'"wget $novoGit has failed"; keep_clean; exit 1; fi


if [[ -d "$novoSrc" ]]; then 
	rm -r "$novoSrc"
fi

# extract
debug_step="decompress $novoTgz"
tar -zxvf "$novoTgz"
debug_location
# if [[ "$?" != 0 ]]; then echo $'\n'"decompress $novoTgz has failed"; keep_clean; exit 1; fi

cd "$novoSrc" || echo "unable to cd to $novoSrc"

##build db4 on some bsds and set versions##
if [[ "$novoBsd" == 2 ]]; then
	echo $'\n'"installing db4..."$'\n'
	BDB_PREFIX="${novoSrc}/db4"
	mkdir -p "$BDB_PREFIX"
	# curl -o db-4.8.30.NC.tar.gz 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	debug_step="db-4.8.30.NC.tar.gz checksum match"
	echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256 -c
	debug_location
	debug_step="untar db-4.8.30.NC.tar.gz"
	tar -zxvf db-4.8.30.NC.tar.gz
	debug_location
	debug_step="make db4"
	cd db-4.8.30.NC/build_unix/
	../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX CC=clang CXX=clang++ # CPP=ecpp
	make install
	debug_location
# wget https://raw.githubusercontent.com/bitsko/bitcoin-related/main/bitcoin/install_db4.sh
# wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/install_db4.sh
#	chmod +x install_db4.sh
#	./install_db4.sh `pwd`
#	export BDB_PREFIX="$PWD/db4"
#	export AUTOCONF_VERSION=2.71
#	export AUTOMAKE_VERSION=1.16
fi
#############

# autogen
./autogen.sh

# configure with specific instructions
debug_step="./configure"
if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]] && [[ "$novoBSD" == 0 ]]; then
	CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site \
	./configure --without-gui --enable-reduce-exports LDFLAGS=-static-libstdc++
elif [[ "${x86cpu_array[*]}" =~ "$cpu_type" ]] && [[ "$novoBSD" == 0 ]]; then
	./configure --without-gui
elif [[ "$novoBsd" == 1 ]]; then
	./configure --without-gui --disable-dependency-tracking \
	--disable-hardening --with-incompatible-bdb \
	MAKE=gmake CXX=clang++ CC=clang \
	CFLAGS="-I/usr/local/include -I/usr/include/machine" \
	CXXFLAGS="-I/usr/local/include -I/usr/local/include/db5" \
	LDFLAGS="-L/usr/local/lib -L/usr/local/lib/db5" \
	BDB_LIBS="-ldb_cxx-5" \
        BDB_CFLAGS="-I/usr/local/include/db5" 
elif [[ "$novoBsd" == 2 ]]; then 
	export AUTOCONF_VERSION=2.71
	export AUTOMAKE_VERSION=1.16
	export BDB_PREFIX="$novoSrc/db4" 
	./configure --without-gui \
	MAKE=gmake CXX=clang++ CC=clang \
#	MAKE=gmake CXX=eg++ CC=egcc CPP=ecpp \
#	BDB_PREFIX="$PWD/db4" \
#	AUTOCONF_VERSION=2.71 \
#	AUTOMAKE_VERSION=1.16 \
#	CFLAGS="-I/usr/local/include -I/usr/include/machine" \
#        CXXFLAGS="-I/usr/local/include -I${BDB_PREFIX}/include" \
#        LDFLAGS="-L/usr/local/lib -L${BDB_PREFIX}/lib" \
        BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" \
        BDB_CFLAGS="-I${BDB_PREFIX}/include" 
fi
debug_location
# if [[ "$?" != 0 ]]; then echo $'\n'"./configure failed"; keep_clean; script_exit; unset -f script_exit; exit 1; fi

# make
# debug_step="make/gmake package"
if [[ "$novoBsd" != 0 ]]; then
	gmake
else
#	novoPrc=$(echo "$(nproc) - 1" | bc)
#	if [[ "$novoPrc" == 0 ]]; then novoPrc="1"; fi
	make # -j "$novoPrc"
fi
# debug_location
# if [[ "$?" != 0 ]]; then echo $'\n'"make package failed"; keep_clean; script_exit; unset -f script_exit; exit 1; fi

# copies and strips the executables, placing them in .novo/bin
if [[ ! -d "$novoBin" ]]; then mkdir "$novoBin"; fi
debug_step="binary creation"
cp src/novod "$novoBin"/novod && strip "$novoBin"/novod
cp src/novo-cli "$novoBin"/novo-cli && strip "$novoBin"/novo-cli
cp src/novo-tx "$novoBin"/novo-tx && strip "$novoBin"/novo-tx

# if successful, print location of binaries to terminal

debug_location
debug_step="conf creation"
echo $'\n'"binaries available in $novoBin"$'\n'
ls "$novoBin"
echo $'\n'"to use:"
echo "$novoBin/novod --daemon"
echo "tail -f $novoDir/debug.log"
echo "$novoBin/novo-cli --help"
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
debug_location
script_exit
unset -f script_exit
