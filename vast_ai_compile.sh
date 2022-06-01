#!/bin/bash
# wget && chmod +x vast_ai_compile.sh && ./vast_ai_compile.sh
apt update && apt upgrade -y && sed -i 's/bionic/focal/g' /etc/apt/sources.list && \
apt update && apt -y upgrade && \
apt -y install screen libjansson4 ocl-icd-* \
       opencl-headers libcurl4-openssl-dev pkg-config libtool autoconf \
       git build-essential libncurses5-dev autogen automake && \
git clone https://github.com/Bit90pool/novo-cgminer && \
cd novo-cgminer && \
./autogen.sh --enable-opencl && \
CFLAGS="-O2 -Wall -march=native" ./configure 
make
echo "./cgminer -o stratum+tcp://mine.bit90.io:3333 -u youraddy.minername -p password -k diablo"
