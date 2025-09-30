#!/bin/bash

# install prequisitions
sudo apt update && sudo apt install -y build-essential git curl wget vim tree unzip p7zip-full net-tools htop jq ripgrep fd-find bat pkg-config libtool libssl-dev libffi-dev libsqlite3-dev libreadline-dev libbz2-dev libncurses5-dev libgdbm-dev liblzma-dev zlib1g-dev libxml2-dev libxslt1-dev libyaml-dev libgmp-dev libpcre3-dev tk-dev clangd cmake openssh-server openssh-client -y

# bitcoin daemon dependencies (https://github.com/bitcoin/bitcoin/blob/master/doc/dependencies.md)
sudo apt install -y autotools-dev automake bsdmainutils python3 libevent-dev libminiupnpc-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler capnproto libcapnp-dev pkgconf systemtap-sdt-dev

# sys check  
sudo apt install -y lm-sensors smartmontools sysstat stress memtest86+ fio

# pick full install or partial install what you need
sudo apt install -y libboost-all-dev
sudo apt install -y libboost-system-dev libboost-filesystem-dev libboost-test-dev libboost-thread-dev

# utils
sudo apt install -y radare2 hping3  

# x86inc.asm
wget https://raw.githubusercontent.com/FFmpeg/FFmpeg/master/libavutil/x86/x86inc.asm

# install asdf -> plugin add -> install -> set global language version

# ~/.bashrc add asdf PATH and gobin, npm config get prefix, etc...

# install language server

# install helix and copy config from github

# etc
npm install -g wscat
go install golang.org/x/tools/gopls@latest
