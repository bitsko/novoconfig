#!/bin/bash

# novo_cpuminer.sh
# use at your own risk

# compile and pool mine using:
# https://github.com/benkno/novo-bfgminer

# to download and compile the cpu miner try:
# wget -N https://raw.githubusercontent.com/bitsko/novoconfig/main/novo_cpuminer.sh && chmod +x novo_cpuminer.sh && ./novo_cpuminer.sh

novo_os_release=$(source /etc/os-release; echo $ID)
if [[ "$novo_os_release" == "debian" ]] || [[ "$novo_os_release" == "ubuntu" ]]; then
	sudo apt update
	declare -a dpkg_pkg_array_=( autoconf libjansson4 libjansson-dev libgcrypt20-dev libncurses-dev \
	  libevent-dev libtool uthash-dev libcurl4-openssl-dev curl make yasm wget git bc )
	while read -r line; do
        if ! dpkg -s "$line" &> /dev/null
                then sudo apt -y install "$line"
		if [[ "$?" != 0 ]]; then echo "package update failed"; exit 1; fi
        fi
	done <<<$(printf '%s\n' "${dpkg_pkg_array_[@]}")
	unset dpkg_pkg_array_
elif [[ "$novo_os_release" == "manjaro-arm" ]] || [[ "$novo_os_release" == "manjaro" ]]; then
	declare -a arch_pkg_array_=( libtool libevent autoconf automake jansson uthash curl ncurses \
		libgcrypt pkgconf make yasm wget git bc )
	while read -r line; do
        	if ! pacman -Qi "$line" &> /dev/null
                	then sudo pacman --noconfirm -Syu "$line"
			if [[ "$?" != 0 ]]; then echo "package update failed"; exit 1; fi
	        fi
	done <<<$(printf '%s\n' "${arch_pkg_array_[@]}")
	unset arch_pkg_array_
fi

git clone https://github.com/benkno/novo-bfgminer
if [[ "$?" != 0 ]]; then echo "git cloning failed"; exit 1; fi

cd novo-bfgminer
git config --global url.https://github.com/.insteadOf git://github.com/
./autogen.sh
./configure --enable-cpumining

make_proc_count=$(echo "$(nproc) - 1" | bc)
if [[ $make_proc_count == 0 ]]; then make_proc_count=$((make_proc_count + 1)); fi
make -j "$make_proc_count"

echo $'\n'"to cpu pool mine:"
echo $'\n'"$PWD/bfgminer --algo fastauto -S cpu:auto --cpu-threads $(nproc) -o stratum+tcp://mine.bit90.io:3333 -u 1NTAraUNiLw1tynMSMv9WFvKrpEVoMhaSe.test -p password"

unset novo_os_release make_proc_count
