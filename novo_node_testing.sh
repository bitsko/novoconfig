#!/usr/bin/env bash

# compile the latest version of novo node

# wget -N https://raw.githubusercontent.com/bitsko/novoconfig/main/novo_node_compile.sh && chmod +x novo_node_compile.sh && ./novo_node_compile.sh

progress_banner(){ echo $'\n\n'"${novoTxt} ${debug_step} ${novoTxt}"$'\n\n'; sleep 1; }

keep_clean(){ if [[ "$frshDir" == 1 ]]; then rm -r "$novoDir" "$novoTgz" 2>/dev/null; fi; }

debug_location(){
	if [[ "$?" != 0 ]]; then
		echo $'\n\n'"$debug_step has failed!"$'\n\n'
		keep_clean
		script_exit
		exit 1
	fi; }

script_exit(){ unset \
		novoUsr novoRpc novoCpu novoAdr novoDir novoCnf novoVer novoTgz novoGit \
		novoTxt novoSrc novoNum archos_array deb_os_array armcpu_array x86cpu_array \
		bsdpkg_array redhat_array cpu_type pkg_Err uname_OS novoBsd novoPrc debug_step \
		novo_OS novoBar keep_clean; }

novoTxt="***********************"
novoBar="$novoTxt $novoTxt $novoTxt"
novoBsd=0

echo "$novoBar"
debug_step="novo node compile script"; progress_banner
echo "$novoBar"

debug_step="declare arrays with bash v4+"
declare -a bsdpkg_array=( freebsd OpenBSD )
declare -a redhat_array=( fedora )
declare -a deb_os_array=( debian ubuntu raspbian linuxmint pop )
declare -a archos_array=( manjaro-arm manjaro endeavouros arch )
declare -a armcpu_array=( aarch64 aarch64_be armv8b armv8l armv7l )
declare -a x86cpu_array=( i686 x86_64 i386 ) # amd64
debug_location

debug_step="find the operating system type"
cpu_type="$(uname -m)"
uname_OS="$(uname -s)"
novo_OS=$(if [[ -f /etc/os-release ]]; then source /etc/os-release; echo "$ID";	fi; )
if [[ -z "$novo_OS" ]]; then novo_OS="$uname_OS"; fi
if [[ "$novo_OS" == *"BSD" ]]; then novoBsd=2; fi
if [[ "$novo_OS" == "Linux" ]]; then echo "Linux distribution type unknown; cannot check for dependencies"; fi

debug_step="dependencies installation"; progress_banner
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
		unset dpkg_to_install
        fi
	if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
		if ! dpkg -s g++ &> /dev/null; then
			sudo apt -y install g++-arm-linux-gnueabihf
			debug_location
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
		fi
	done <<<$(printf '%s\n' "${arch_pkg_array_[@]}")
	unset arch_pkg_array_
        if [[ -n "${arch_to_install[*]}" ]]; then
       	        sudo pacman --noconfirm -Sy ${arch_to_install[*]}
       		debug_location
                unset arch_to_install
       	fi
	if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
		if ! pacman -Qi arm-none-eabi-binutils &> /dev/null; then
			sudo pacman --noconfirm -Sy arm-none-eabi-binutils
			debug_location
		fi
                if ! pacman -Qi arm-none-eabi-gcc &> /dev/null;	then
			sudo pacman --noconfirm -Sy arm-none-eabi-gcc
			debug_location
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
		elif [[ "$novoBsd" == 2 ]]; then
			pkg_add ${pkg_to_install_[*]}
			debug_location
		fi
	fi
elif [[ "$novo_OS" == "Linux" ]]; then
	echo "attempting to compile without checking dependencies"
else
	echo "$novo_OS unsupported"
	script_exit
	unset -f script_exit
	exit 1
fi
# end dependency installation script

debug_step="setting installation variables and curl-ing the release version"
novoDir="$HOME/.novo"
novoBin="$novoDir/bin"
novoCnf="$novoDir/novo.conf"
novoVer="$(curl -s https://api.github.com/repos/novoworks/novo/releases/latest | jq .tag_name | sed 's/"//g' )"
debug_location
novoTgz="$novoVer".tar.gz
novoGit="https://github.com/novoworks/novo/archive/refs/tags/$novoTgz"
novoNum="${novoVer//v/}"
novoSrc="$PWD/novo-$novoNum"
frshDir=0

debug_step="making directories, backing up .novo folder if present"
if [[ ! -d "$novoDir" ]]; then
	mkdir "$novoDir"
	debug_location
	frshDir=1
elif [[ -d "$novoDir" ]]; then
	echo $'\n'"backing up existing novo directory"$'\n'
	IFS= read -r -p "stop your node first if running. press enter to continue"
	cp -r "$novoDir" "$HOME"/novo."$EPOCHSECONDS".backup
	debug_location
	echo "existing .novo folder backed up to: $HOME/novo.$EPOCHSECONDS.backup"
fi

debug_step="wget $novoTgz download"; progress_banner
if [[ ! -f "$novoTgz" ]]; then
	wget "$novoGit"
else
	echo "$novoTgz already downloaded"
fi
debug_location

debug_step="removing pre-existing source compile folder"
if [[ -d "$novoSrc" ]]; then 
	rm -r "$novoSrc"
fi
debug_location

debug_step="decompress $novoTgz"; progress_banner
tar -zxvf "$novoTgz"
debug_location

cd "$novoSrc" || echo "unable to cd to $novoSrc"

##build db4 on some bsds##
# if [[ "$novoBsd" == 2 ]]; then
#	debug_step="db4 install"
#	echo $'\n'"installing db4..."$'\n'
#	wget https://raw.githubusercontent.com/bitsko/bitcoin-related/main/bitcoin/install_db4.sh
#	echo $'\n\n'"${novoTxt} ${debug_step} ${novoTxt}"$'\n\n'
#	if [[ ! -d "db4" ]]; then mkdir db4; fi
#	bash install_db4.sh "$PWD"
#	debug_location
# fi

# autogen
debug_step="running autogen.sh"; progress_banner
if [[ "$novoBsd" == 2 ]]; then
	export AUTOCONF_VERSION=2.71
	export AUTOMAKE_VERSION=1.16
#	export BDB_PREFIX="$PWD/db4"
#	export BDB_VERSION='db-4.8.30.NC'
#	debug_step="autoreconf --install"; progress_banner
#	autoreconf --install
#	debug_location
#	debug_step="automake --add-missing"; progress_banner
#	automake --add-missing
#	debug_location
#	debug_step="./autogen.sh --system"; progress_banner
#	./autogen.sh --system
#	debug_step="autoupdate"; progress_banner
#	autoupdate
#	debug_location
#	debug_step="autogen.sh"; progress_banner
	./autogen.sh
#	debug_location
else
	./autogen.sh
fi	
debug_location

debug_step="running ./configure"; progress_banner

if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]] && [[ "$novoBsd" == 0 ]]; then
	CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site \
	./configure --without-gui --enable-reduce-exports LDFLAGS=-static-libstdc++
	debug_location
elif [[ "${x86cpu_array[*]}" =~ "$cpu_type" ]] && [[ "$novoBsd" == 0 ]]; then
	./configure --without-gui
	debug_location
elif [[ "$novoBsd" == 1 ]]; then
	./configure --without-gui --disable-dependency-tracking \
	--disable-hardening --with-incompatible-bdb \
	MAKE=gmake CXX=clang++ CC=clang \
	CFLAGS="-I/usr/local/include -I/usr/include/machine" \
	CXXFLAGS="-I/usr/local/include -I/usr/local/include/db5" \
	LDFLAGS="-L/usr/local/lib -L/usr/local/lib/db5" \
	BDB_LIBS="-ldb_cxx-5" \
        BDB_CFLAGS="-I/usr/local/include/db5" 
	debug_location
elif [[ "$novoBsd" == 2 ]]; then 
	./configure --without-gui \ # --with-incompatible-bdb \
	--disable-wallet \
#	MAKE=gmake \
#	--build="x86_64-unknown-openbsd7.1" \	
#	--host="x86_64-unknown-openbsd7.1" \
#	--target="x86_64-unknown-openbsd7.1" \
	MAKE=gmake CXX=clang++ CC=clang \ # CPP=clang-cpp \
#	MAKE=gmake CXX=eg++ CC=egcc \ # CPP=ecpp \
	CFLAGS="-I/usr/local/include -I/usr/include/machine" \
        CXXFLAGS="-I/usr/local/include" \ # -I${BDB_PREFIX}/include" \
        LDFLAGS="-L/usr/local/lib" \ # -L${BDB_PREFIX}/lib" \
#        BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" \
#        BDB_CFLAGS="-I${BDB_PREFIX}/include" 
	debug_location
fi

debug_step="make/gmake package"; progress_banner

if [[ "$novoBsd" != 0 ]]; then
	gmake
else
	novoPrc=$(echo "$(nproc) - 1" | bc)
	if [[ "$novoPrc" == 0 ]]; then novoPrc="1"; fi
	make -j "$novoPrc"
fi
debug_location

debug_step="copying and stripping binaries into $novoBin"
if [[ ! -d "$novoBin" ]]; then mkdir "$novoBin"; fi


cp src/novod "$novoBin"/novod && strip "$novoBin"/novod
cp src/novo-cli "$novoBin"/novo-cli && strip "$novoBin"/novo-cli
cp src/novo-tx "$novoBin"/novo-tx && strip "$novoBin"/novo-tx
debug_location

if [[ ! -f "$novoCnf" ]]; then
	debug_step="creating conf"; progress_banner
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
	debug_location
	cat "$novoCnf"
fi

echo $'\n'"binaries available in $novoBin"$'\n'
ls "$novoBin"
echo $'\n'"to use:"
echo "$novoBin/novod --daemon"
echo "tail -f $novoDir/debug.log"
echo "$novoBin/novo-cli --help"

script_exit
unset -f script_exit
