#!/bin/bash
# vast.ai image: nvidia/opencl
# bit90pool novo-cgminer compilation script

apt update && apt -y upgrade && \
apt -y install screen libjansson4 ocl-icd-* \
        opencl-headers libcurl4-openssl-dev pkg-config libtool autoconf \
        git build-essential libncurses5-dev autogen automake && \
git clone https://github.com/Bit90pool/novo-cgminer && \
cd novo-cgminer && \
./autogen.sh --enable-opencl && \
CFLAGS="-O2 -Wall -march=native" ./configure && \
make
# to run:
# ./cgminer -o stratum+tcp://mine.bit90.io:3333 -u yournovoaddresshere.yourminername -p password -k diablo
