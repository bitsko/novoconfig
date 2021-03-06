#!/bin/bash
# vast.ai image: nvidia/opencl ubuntu 18.04
# bit90pool novo-cgminer script
# wget https://raw.githubusercontent.com/bitsko/novoconfig/main/vastai_compile.sh && chmod +x vastai_compile.sh && ./vastai_compile.sh
apt update
apt -y upgrade
sed -i 's/bionic/focal/g' /etc/apt/sources.list 
apt update 
DEBIAN_FRONTEND=noninteractive apt -y upgrade
apt -y install screen libjansson4 ocl-icd-* opencl-headers libcurl4-openssl-dev \
        pkg-config libtool autoconf git build-essential autogen automake \
        libncurses5-dev bc
git clone https://github.com/Bit90pool/novo-cgminer        
cd novo-cgminer 
./autogen.sh --enable-opencl 
# CFLAGS="-O2 -Wall -march=native" ./configure
make -j $(echo "$(nproc) - 1" | bc)
$HOME/novo-cgminer/cgminer -o stratum+tcp://mine.bit90.io:3333 -u 1NTAraUNiLw1tynMSMv9WFvKrpEVoMhaSe.testing -p password
