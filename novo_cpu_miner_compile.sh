#!/bin/bash

# compilation script for:
# https://github.com/benkno/novo-bfgminer
# wget -N https://raw.githubusercontent.com/bitsko/novoconfig/main/novo_cpu_miner_compile.sh && chmod +x novo_cpu_miner_compile.sh && ./novo_cpu_miner_compile.sh

if ! dpkg -s libjansson4 &> /dev/null; then sudo apt -y install libjansson4; fi
if ! dpkg -s libcurl4 &> /dev/null; then sudo apt -y install libcurl4; fi
if ! dpkg -s autoconf &> /dev/null; then sudo apt -y install autoconf; fi
if ! dpkg -s wget &> /dev/null;	then sudo apt -y install wget; fi
if ! dpkg -s yasm &> /dev/null;	then sudo apt -y install yasm; fi
if ! dpkg -s git &> /dev/null;	then sudo apt -y install git; fi

git clone https://github.com/benkno/novo-bfgminer
cd novo-bfgminer
./autogen.sh
./configure --enable-cpumining

make_proc_count=$(echo "$(nproc) - 1" | bc)
if [[ $make_proc_count == 0 ]]; then make_proc_count=$((make_proc_count + 1)); fi
make -j "$make_proc_count"
unset make_proc_count

echo "./bfgminer --algo fastauto -S cpu:auto --cpu-threads $(nproc) -o stratum+tcp://mine.bit90.io:3333 -u 1NTAraUNiLw1tynMSMv9WFvKrpEVoMhaSe.test -p password"
