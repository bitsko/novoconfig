#!/usr/bin/env bash

# compile the latest version of novo node

# wget -N https://raw.githubusercontent.com/bitsko/novoconfig/main/novo_node_compile.sh && chmod +x novo_node_compile.sh && ./novo_node_compile.sh

progress_banner(){ echo $'\n\n'"${novoTxt} ${debug_step} ${novoTxt}"$'\n\n'; sleep 2; }
minor_progress(){ echo "	***** $debug_step *****"; sleep 1; }
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
		bsdpkg_array redhat_array cpu_type pkg_Err uname_OS novoPrc debug_step \
		novo_OS novoBar keep_clean bsd__pkg_array_ frshDir compile_bdb53 novoTxt \
		progress_banner minor_progress compile_boost wallet_disabled; }


novoTxt="***********************"
novoBar="$novoTxt $novoTxt $novoTxt"
novoBsd=0
compile_bdb53=0
compile_boost=0
wallet_disabled=0

echo "$novoBar"; debug_step="novo node compile script"; progress_banner

debug_step="declare arrays with bash v4+"
declare -a bsdpkg_array=( freebsd OpenBSD NetBSD )
declare -a redhat_array=( fedora centos rocky amzn )
declare -a deb_os_array=( debian ubuntu raspbian linuxmint pop )
declare -a archos_array=( manjaro-arm manjaro endeavouros arch )
declare -a armcpu_array=( aarch64 aarch64_be armv8b armv8l armv7l )
declare -a x86cpu_array=( i686 x86_64 i386 ) # amd64
debug_location
cpu_type="$(uname -m)"
uname_OS="$(uname -s)"
novo_OS=$(if [[ -f /etc/os-release ]]; then source /etc/os-release; echo "$ID";	fi; )
debug_step="find the operating system type"
if [[ -z "$novo_OS" ]]; then novo_OS="$uname_OS"; fi
if [[ "$novo_OS" == "Linux" ]]; then echo "Linux distribution type unknown; cannot check for dependencies"; fi
debug_step="compiling for: $novo_OS $cpu_type"; progress_banner; echo "$novoBar"

debug_step="dependencies installation"; progress_banner
if [[ "${deb_os_array[*]}" =~ "$novo_OS" ]]; then
	sudo apt update
	sudo apt -y upgrade
	declare -a dpkg_pkg_array_=( build-essential libtool autotools-dev pkg-config \
		bsdmainutils python3 libevent-dev libboost-system-dev libboost-filesystem-dev \
		libboost-chrono-dev libboost-program-options-dev libboost-test-dev automake \
		libboost-thread-dev libsqlite3-dev libqrencode-dev libdb-dev libdb++-dev \
		libssl-dev miniupnpc bc curl jq wget libzmq3-dev xxd )
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
		sed miniupnpc jq wget bc vim )
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
elif [[ "${redhat_array[*]}" =~ "$novo_OS" ]]; then
        sudo dnf update
        if [[ "$novo_OS" == fedora  || "$novo_OS" == amzn ]]; then
		declare -a rhat_pkg_array_=( gcc-c++ libtool make autoconf automake openssl-devel \
			libevent-devel boost-devel libdb-devel libdb-cxx-devel miniupnpc-devel \
			qrencode-devel gzip jq wget bc vim sed grep zeromq-devel )
        elif [[ "$novo_OS" == centos || "$novo_OS" == rocky ]]; then
	                declare -a rhat_pkg_array_=( libtool make autoconf automake openssl-devel \
                        libevent-devel boost-devel gcc-c++ gzip jq wget bc vim sed grep libuuid-devel )
	                # miniupnpc-devel qrencode-devel zeromq-devel libdb-devel
	else
		echo "$uname_OS unsupported"
		exit 1
	fi
	while read -r line; do
                if ! rpm -qi "$line" &> /dev/null; then
                        rhat_to_install+=( "$line" )
                        debug_location
                fi
        done <<<$(printf '%s\n' "${rhat_pkg_array_[@]}")
        unset rhat_pkg_array_
        if [[ -n "${rhat_to_install[*]}" ]]; then
               	if [[ -n $(command -v dnf) ]]; then
			sudo dnf install -y ${rhat_to_install[*]}
                else
			sudo yum install -y ${rhat_to_install[*]}
		fi
		debug_location
		unset rhat_to_install
        fi
        if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]]; then
                if ! rpm -qi arm-none-eabi-binutils &> /dev/null; then
                        sudo dnf install -y arm-none-eabi-binutils
                        debug_location
                fi
                if ! rpm -qi arm-none-eabi-gcc &> /dev/null; then
                        sudo dnf install -y arm-none-eabi-gcc
                        debug_location
                fi
        fi
elif [[ "${bsdpkg_array[*]}" =~ "$novo_OS" ]]; then
	novoBsd=1
	if [[ "$uname_OS" == OpenBSD ]]; then
		# compile_bdb53=1
		# compile_boost=1
		declare -a bsd__pkg_array_=( libevent libqrencode pkgconf miniupnpc jq \
			curl wget gmake python-3.9.13 sqlite3 nano zeromq openssl boost \
			libtool-2.4.2p2 autoconf-2.71 automake-1.16.3 vim-8.2.4600-no_x11 )
			# llvm boost git g++-11.2.0p2 gcc-11.2.0p2
	elif [[ "$uname_OS" == NetBSD ]]; then
		if [[ -z $(command -v pkgin) ]]; then
			pkg_add pkgin
		fi
		declare -a bsd__pkg_array_=( libtool libevent qrencode pkgconf miniupnpc \
			jq curl wget gmake python39 sqlite3 boost nano zeromq openssl autoconf \
			automake ca-certificates boost-libs readline vim llvm clang )
			# db5 llvm clang gcc9 R-BH-1.75.0.0
	elif [[ "$novo_OS" == freebsd ]]; then
		pkg upgrade -y
		declare -a bsd__pkg_array_=( boost-all libevent autotools libqrencode curl \
			octave-forge-zeromq libnpupnp nano fakeroot pkgconf miniupnpc gzip \
			jq wget db5 libressl gmake python3 sqlite3 binutils gcc clang vim )
	else
		echo "$novo_OS bsd distro not supported"
	fi
	while read -r line; do 
		if ! command -v "$line" >/dev/null; then
			pkg_to_install_+=( "$line" )
		fi
	done <<<$(printf '%s\n' "${bsd__pkg_array_[@]}")
	
	if [[ -n "${pkg_to_install_[*]}" ]]; then
		if [[ "$novo_OS" == freebsd ]]; then
			pkg install -y ${pkg_to_install_[*]}
			debug_location
		elif [[ "$uname_OS" == "OpenBSD" ]] || [[ "$uname_OS" == "NetBSD" ]]; then
			if [[ -n $(command -v pkgin) ]]; then
				pkgin install ${pkg_to_install_[*]}
			else
				pkg_add ${pkg_to_install_[*]}
			fi
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

debug_step="curl-ing the release version"; minor_progress
novoDir="$HOME/.novo"
novoBin="$novoDir/bin"
novoCnf="$novoDir/novo.conf"
if [[ -n $(command -v jq) ]]; then
	novoVer="$(curl -s https://api.github.com/repos/novoworks/novo/releases/latest | jq .tag_name | sed 's/"//g' )"
else 
	echo "*** jq not installed, dependencies installation failed"
	exit 1
fi
debug_location
novoTgz="$novoVer".tar.gz
novoGit="https://github.com/novoworks/novo/archive/refs/tags/$novoTgz"
novoNum="${novoVer//v/}"
novoSrc="$PWD/novo-$novoNum"
frshDir=0

debug_step="making directories, backing up .novo folder if present"; minor_progress
if [[ ! -d "$novoDir" ]]; then
	mkdir "$novoDir"
	debug_location
	frshDir=1
elif [[ -d "$novoDir" ]]; then
	debug_step="backing up existing novo directory"; progress_banner
	if [[ -f "$novoDir/novo.pid" ]]; then
		IFS= read -r -p "stop your node first if running. press enter to continue"
		novoPid=$(cat "$novoDir"/novod.pid)
		echo "kill $novoPid"
		echo "or $novoBin/novo-cli stop"
		unset novoPid
	fi
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

debug_step="removing pre-existing source compile folder"; minor_progress
if [[ -d "$novoSrc" ]]; then 
	rm -r "$novoSrc"
fi
debug_location

debug_step="decompress $novoTgz"; progress_banner
tar -zxvf "$novoTgz"
debug_location

cd "$novoSrc" || echo "unable to cd to $novoSrc"
# compile  BerkeleyDB.5.3 on some platforms
if [[ "$compile_bdb53" == 1 ]]; then
	debug_step="compiling BerkeleyDB.5.3"; progress_banner; debug_step="wget db-5.3.28"; minor_progress
	wget https://github.com/berkeleydb/libdb/releases/download/v5.3.28/db-5.3.28.tar.gz
	debug_location; debug_step="untar db-5.3"; minor_progress
	tar -zxvf db-5.3.28.tar.gz
	debug_location; debug_step="configure db-5.3"; minor_progress
	cd db-5.3.28 || echo "unable to cd to $PWD/db-5.3.28"
	debug_step="applying atomic patch"; minor_progress
	sed -i 's/__atomic_compare_exchange((p), (o), (n))/__atomic_compare_exchange_db((p), (o), (n))/g' src/dbinc/atomic.h; debug_location
	sed -i 's/static inline int __atomic_compare_exchange/static inline int __atomic_compare_exchange_db/g' src/dbinc/atomic.h; debug_location
	cd build_unix || echo "unable to cd to $PWD/build_unix"
	../dist/configure --enable-cxx --prefix=/usr/local --disable-shared --with-pic CC=egcc CXX=eg++ CPP=ecpp
	# CC=clang CXX=clang++ CPP=clang-cpp
	debug_location; debug_step="make db5"; minor_progress
	make
	debug_location; debug_step="make install db5"; minor_progress
	make install
	debug_location; debug_step="bdb5 compiled"; progress_banner
	cd "$novoSrc" || echo "unable to cd to $novoSrc"
fi
if [[ "$compile_boost" == 1 ]]; then
	debug_step="compiling boost"; minor_progress
	cd "$novoSrc" || echo "unable to cd to $novoSrc"
	git clone --recursive https://github.com/boostorg/boost.git
	cd boost
	git checkout develop
	echo 'using gcc : : eg++ : <cxxflags>"-fvisibility=hidden -fPIC" <linkflags>"" <archiver>"ar" <striper>"strip"  <ranlib>"ranlib" <rc>"" : ;' > user-config.jam
	config_opts="runtime-link=shared threadapi=pthread threading=multi link=static variant=release --layout=tagged --build-type=complete --user-config=user-config.jam -sNO_BZIP2=1"
	./bootstrap.sh --without-icu --with-libraries=chrono,filesystem,program_options,system,thread,test
	./b2 headers
	cd "$novoSrc" || echo "unable to cd to $novoSrc"
fi
# autogen
debug_step="running autogen.sh"; progress_banner
if [[ "$novo_OS" == OpenBSD ]]; then
	export AUTOCONF_VERSION=2.71
	export AUTOMAKE_VERSION=1.16
	./autogen.sh
else
	./autogen.sh
fi	
debug_location
# "${x86cpu_array[*]}" =~ "$cpu_type" && "$novoBsd" == 0 ]]
# "${armcpu_array[*]}" =~ "$cpu_type" && "$novoBsd" == 0 ]]
debug_step="running ./configure"; progress_banner
if [[ "${armcpu_array[*]}" =~ "$cpu_type" ]] && \
	[[ ! "${redhat_array[*]}" =~ "$novo_OS" && ! "${bsdpkg_array[*]}" =~ "$novo_OS" ]]; then
	CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site \
	./configure --without-gui --enable-reduce-exports LDFLAGS=-static-libstdc++
	debug_location
elif [[ "${x86cpu_array[*]}" =~ "$cpu_type" ]] && \
	[[ ! "${redhat_array[*]}" =~ "$novo_OS" && ! "${bsdpkg_array[*]}" =~ "$novo_OS" ]]; then
	./configure --without-gui
	debug_location
elif [[ "$novo_OS" == fedora ]]; then 
	./configure --without-gui
	debug_location
elif [[ "$novo_OS" == freebsd ]]; then
	./configure --without-gui --disable-dependency-tracking \
	--disable-hardening --with-incompatible-bdb \
	MAKE=gmake CXX=clang++ CC=clang \
	CFLAGS="-I/usr/local/include -I/usr/include/machine" \
	CXXFLAGS="-I/usr/local/include -I/usr/local/include/db5" \
	LDFLAGS="-L/usr/local/lib -L/usr/local/lib/db5" \
	BDB_LIBS="-ldb_cxx-5" \
        BDB_CFLAGS="-I/usr/local/include/db5" 
	debug_location
elif [[ "$novo_OS" == OpenBSD ]]; then 
	./configure \
	--without-gui \
	--disable-dependency-tracking \
	--disable-wallet \
	MAKE=gmake
	debug_location
	wallet_disabled=1
elif [[ "$novo_OS" == NetBSD ]]; then
	export BOOST_ROOT="/usr/pkg/include/boost"
	./configure --without-gui --disable-dependency-tracking \
	--disable-wallet \
	--with-boost=$BOOST_ROOT \
	MAKE=gmake CXX=clang++ CC=clang 
	debug_location
	wallet_disabled=1
elif [[ "$novo_OS" == centos ]]; then
	./configure --without-gui \
	--disable-wallet
	debug_location
	wallet_disabled=1
elif [[ "$novo_OS" == amzn ]]; then
	./configure --without-gui \
	--with-incompatible-bdb \
	--disable-wallet
	debug_location
	wallet_disabled=1
elif [[ "$novo_OS" == rocky ]]; then
	./configure --without-gui \
	--disable-wallet
	debug_location
	wallet_disabled=1
fi
debug_step="make/gmake package"; progress_banner
if [[ "${bsdpkg_array[*]}" =~ "$novo_OS" ]]; then
	gmake
else
	novoPrc=$(echo "$(nproc) - 1" | bc)
	if [[ "$novoPrc" == 0 ]]; then novoPrc="1"; fi
	make -j "$novoPrc"
fi
debug_location

debug_step="copying and stripping binaries into $novoBin"; minor_progress
if [[ ! -d "$novoBin" ]]; then mkdir "$novoBin"; fi
cp src/novod "$novoBin"/novod && strip "$novoBin"/novod
cp src/novo-cli "$novoBin"/novo-cli && strip "$novoBin"/novo-cli
cp src/novo-tx "$novoBin"/novo-tx && strip "$novoBin"/novo-tx
debug_location

if [[ ! -f "$novoCnf" ]]; then
	debug_step="creating conf"; progress_banner
	novoUsr="$(xxd -l 16 -p /dev/urandom)"
	novoRpc="$(xxd -l 20 -p /dev/urandom)"
	echo \
	"port=8666"$'\n'\
	"rpcport=8665"$'\n'\
	"rpcuser=$novoUsr"$'\n'\
	"rpcpassword=$novoRpc"$'\n'\
	"gen=1"$'\n'\
	"txindex=1"$'\n'\
	"maxmempool=1600" \
	| tr -d ' ' > "$novoCnf"
	debug_location
	cat "$novoCnf"
fi

debug_step="binaries available in $novoBin:"; minor_progress
ls "$novoBin"
debug_location
if [[ "$wallet_disabled" == 1 ]]; then
	debug_step="wallet build is presently disabled on $novo_OS"; progress_banner
	echo "please submit a pull request or comment on how to build the wallet to the repo at:"
	echo "https://github.com/bitsko/novoconfig"
fi
echo $'\n'"to use:"
echo "$novoBin/novod --daemon"
echo "tail -f $novoDir/debug.log"
echo "$novoBin/novo-cli --help"
script_exit
unset -f script_exit



# openbsd	BDB_LIBS="-ldb_cxx-5" \
#        BDB_CFLAGS="-I/usr/local/include/db5" 
#	MAKE=gmake CC=egcc CXX=eg++ \
#	CXXFLAGS="-I/usr/local/include -I/usr/local/BerkeleyDB.5.3/include" \
#	LDFLAGS="-L/usr/local/lib -L/usr/local/BerkeleyDB.5.3/lib -lboost_system" \
#	BDB_LIBS="-L/usr/local/lib -L/usr/local/BerkeleyDB.5.3/lib -ldb_cxx" \
#	BDB_CFLAGS="-I/usr/local/BerkeleyDB.5.3/include"
	debug_location
#################################################################
# netbsd
#	export BOOST_ROOT="/usr/pkg/include/boost"
#	export PKGSRC_GCC_VERSION="9.3.0"
#	export PKGSRC_GXX_VERSION="9.3.0"
#	MAKE=gmake
#	--with-boost=$BOOST_ROOT \
#	MAKE=gmake CXX="/usr/pkg/gcc9/bin/g++" CC="/usr/pkg/gcc9/bin/gcc" \ 		
#	CXXFLAGS="-I/usr/pkg/include -I/usr/pkg/gcc9/include -I/usr/pkg/include/boost -I/usr/pkg/include/db5" \
#	LDFLAGS="-L/usr/pkg/lib -L/usr/pkg/include/db5 -L/usr/pkg/lib/boost -L/usr/pkg/lib/db5" \
#	BDB_LIBS="-L/usr/pkg/include/db5 -L/usr/pkg/lib -llibdb5_cxx" \
#       BDB_CFLAGS="-I/usr/pkg/include/db5 -I/usr/pkg/lib" \
#	BOOST_VERSION=107800 \
#	BOOST_LIB_VERSION=1_78 
#	# CXXFLAGS="-I/usr/pkg/include -I/usr/pkg/gcc9/include -I/usr/pkg/include/boost -I/usr/pkg/include/db5" \
#	debug_location
	
	#	CFLAGS="-I/usr/local/include -I/usr/include/machine" \
################################################################

# c entos	CFLAGS="-I/usr/include -I/usr/include/machine" \
#	CXXFLAGS="-I/usr/include -I/usr/pkg/include/db5" \
#	LDFLAGS="-L/usr/lib -L/usr/pkg/lib" \
#	MAKE=gmake \
#	CFLAGS="-I/usr/include -I/usr/include/machine" \
#	CXXFLAGS="-I/usr/include -I/usr/include/libdb" \
#	LDFLAGS="-L/usr/lib64 -L/usr/include/libdb" \
#	BDB_LIBS="-L/usr/lib64 -L/usr/include/libdb" \
#       BDB_CFLAGS="-I/usr/include/libdb -I/usr/lib64" 
# amzn	debug_location 	
#	BDB_LIBS="-L/usr/lib64 -L/usr/include/libdb -ldb_cxx" \
#	BDB_CFLAGS="-I/usr/include/libdb -I/usr/lib64" \
	# CPP=clang-cpp
# rocky
#	CFLAGS="-I/usr/include -I/usr/include/machine" \
#	CXXFLAGS="-I/usr/include -I/usr/include/libdb" \
#	LDFLAGS="-L/usr/lib64 -L/usr/include/libdb" \
#	BDB_LIBS="-L/usr/lib64 -L/usr/include/libdb -llibdb-5.3" \
 #       BDB_CFLAGS="-I/usr/include/libdb -I/usr/lib64" 
	debug_location 	
#	MAKE=gmake \
#	--with-incompatible-bdb \


