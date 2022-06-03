#!/bin/bash
# ################### source build ########################
# wget https://raw.githubusercontent.com/bitsko/novoconfig/main/vast_compile_test.sh && chmod +x vast_compile_test.sh && ./vast_compile_test.sh
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
CFLAGS="-O2 -Wall -march=native" ./configure
make -j $(echo "$(nproc) - 1" | bc)
echo "./cgminer -o stratum+tcp://mine.bit90.io:3333 -u yournovoaddresshere.yourminername -p password -k diablo"
