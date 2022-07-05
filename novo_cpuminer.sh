#!/bin/bash
# novo_cpuminer.sh
# compile and pool mine
# https://github.com/benkno/novo-bfgminer
# wget -N https://raw.githubusercontent.com/bitsko/novoconfig/main/novo_cpuminer.sh && chmod +x novo_cpuminer.sh && ./novo_cpuminer.sh

novo_os_release=$(source /etc/os-release; echo $ID)
if [[ "$novo_os_release" == "debian" || "ubuntu" ]]; then
	sudo apt update
	declare -a dpkg_pkg_array_=( autoconf libjansson4 libjansson-dev libgcrypt20-dev libncurses-dev \
	  libevent-dev libtool uthash-dev libcurl4-openssl-dev curl make yasm wget git bc )
	while read -r line; do
        if ! dpkg -s "$line" &> /dev/null
                then sudo apt -y install "$line"
        fi
	done <<<$(printf '%s\n' "${dpkg_pkg_array_[@]}")
	unset dpkg_pkg_array_
elif [[ "$novo_os_release" == "manjaro-arm" || "manjaro" ]]; then
	declare -a arch_pkg_array_=( libtool autoconf jansson uthash curl make yasm wget git bc )
	while read -r line; do
        	if ! pacman -Qi "$line" &> /dev/null
                	then sudo pacman --noconfirm -Syu "$line"
	        fi
	done <<<$(printf '%s\n' "${arch_pkg_array_[@]}")
	unset arch_pkg_array_
fi

git clone https://github.com/benkno/novo-bfgminer
cd novo-bfgminer
git config --global url.https://github.com/.insteadOf git://github.com/
./autogen.sh
./configure --enable-cpumining

make_proc_count=$(echo "$(nproc) - 1" | bc)
if [[ $make_proc_count == 0 ]]; then make_proc_count=$((make_proc_count + 1)); fi
make -j "$make_proc_count"

echo $'\n'"$PWD/bfgminer --algo fastauto -S cpu:auto --cpu-threads $(nproc) -o stratum+tcp://mine.bit90.io:3333 -u 1NTAraUNiLw1tynMSMv9WFvKrpEVoMhaSe.test -p password"
unset novo_os_release make_proc_count
