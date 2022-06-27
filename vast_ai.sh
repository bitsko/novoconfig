#!/bin/bash
# vast.ai image: nvidia/opencl
# bit90pool novo-cgminer script

# wget https://raw.githubusercontent.com/bitsko/novoconfig/main/vast_ai.sh && chmod +x vast_ai.sh && ./vast_ai.sh

# docker GPU command string 
apt update && apt -y upgrade && sed -i 's/bionic/focal/g' /etc/apt/sources.list && \
        apt update && DEBIAN_FRONTEND=noninteractive apt -y upgrade && apt -y install screen libjansson4 ocl-icd-* \
        opencl-headers libcurl4-openssl-dev pkg-config libtool autoconf && \
        wget https://github.com/Bit90pool/novo-cgminer/releases/download/v1.0/novo-cgiminer-v1.0-ubuntu-20.04.tar.gz && \
        tar -zxvf novo-cgiminer-v1.0-ubuntu-20.04.tar.gz && cd novo-cgminer && \

# edit the line below with address and miner name, and remove the # at the start to deploy with one click
# ./cgminer -o stratum+tcp://mine.bit90.io:3333 -u youraddy.yourname -p password -k diablo

echo    "./cgminer -o stratum+tcp://mine.bit90.io:3333 -u youraddy.yourname -p password -k diablo"
