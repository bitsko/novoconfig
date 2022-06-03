#!/bin/bash
# vast.ai image: nvidia/opencl
# bit90pool novo-cgminer script

# wget https://raw.githubusercontent.com/bitsko/novoconfig/main/vast_ai.sh && chmod +x vast_ai.sh && ./vast_ai.sh

# docker GPU command string 
apt update && apt -y upgrade && sed -i 's/bionic/focal/g' /etc/apt/sources.list && \
        apt update && DEBIAN_FRONTEND=noninteractive apt -y upgrade && apt -y install screen libjansson4 ocl-icd-* opencl-headers libcurl4-openssl-dev pkg-config libtool autoconf && \
        wget https://github.com/Bit90pool/novo-cgminer/releases/download/v1.0/novo-cgiminer-v1.0-ubuntu-20.04.tar.gz && \
        tar -zxvf novo-cgiminer-v1.0-ubuntu-20.04.tar.gz && cd novo-cgminer && \

# edit the line below with address and miner name, and remove the # at the start to deploy with one click
# ./cgminer -o stratum+tcp://mine.bit90.io:3333 -u youraddy.yourname -p password -k diablo

echo    "./cgminer -o stratum+tcp://mine.bit90.io:3333 -u youraddy.yourname -p password -k diablo"





# these scripts below are all broken in some way !

################### 18.04 #########################
# apt update && apt -y upgrade && apt -y install libjansson4 libcurl4-openssl-dev screen nano && \
# wget https://github.com/Bit90pool/novo-cgminer/releases/download/v1.0/novo-cgiminer-v1.0-ubuntu-18.04.tar.gz && \
# tar -zxvf novo-cgiminer-v1.0-ubuntu-18.04.tar.gz && \
# cd novo-cgminer && \
# echo "./cgminer -o stratum+tcp://mine.bit90.io:3333 -u  -p password -k diablo"

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


# !/bin/bash
# wget https://raw.githubusercontent.com/bitsko/novoconfig/main/vast_ai_compile.sh && chmod +x vast_ai_compile.sh && ./vast_ai_compile.sh
# apt update && apt upgrade -y && sed -i 's/bionic/focal/g' /etc/apt/sources.list && \
# apt update && apt -y upgrade && \
# apt -y install screen libjansson4 ocl-icd-* \
#       opencl-headers libcurl4-openssl-dev pkg-config libtool autoconf \
#       git build-essential libncurses5-dev autogen automake && \
# git clone https://github.com/Bit90pool/novo-cgminer && \
# cd novo-cgminer && \
# ./autogen.sh --enable-opencl && \
# CFLAGS="-O2 -Wall -march=native" ./configure 
# make
# echo "./cgminer -o stratum+tcp://mine.bit90.io:3333 -u youraddy.minername -p password -k diablo"
