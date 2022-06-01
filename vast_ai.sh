#!/bin/bash
# vast.ai image: nvidia/opencl
# bit90pool novo-cgminer script

apt update && apt -y upgrade && apt -y install libjansson4 libcurl4-openssl-dev screen nano && \
wget https://github.com/Bit90pool/novo-cgminer/releases/download/v1.0/novo-cgiminer-v1.0-ubuntu-18.04.tar.gz && \
tar -zxvf novo-cgiminer-v1.0-ubuntu-18.04.tar.gz && \
cd novo-cgminer && \
echo "./cgminer -o stratum+tcp://mine.bit90.io:3333 -u  -p password -k diablo"

# ################### source build ########################
# apt update && apt -y upgrade && \
# apt -y install screen libjansson4 ocl-icd-* \
#        opencl-headers libcurl4-openssl-dev pkg-config libtool autoconf \
#        git build-essential libncurses5-dev autogen automake && \
# git clone https://github.com/Bit90pool/novo-cgminer && \
# cd novo-cgminer && \
# ./autogen.sh --enable-opencl && \
# CFLAGS="-O2 -Wall -march=native" ./configure && \
# make
# to run:
# ./cgminer -o stratum+tcp://mine.bit90.io:3333 -u yournovoaddresshere.yourminername -p password -k diablo
