#!/bin/bash

mycelifname="tf0"
workdir=$(mktemp -d --suffix -tftor)

mktorrent() {
    local version="1.1"

    wget https://github.com/pobrn/mktorrent/archive/refs/tags/v${version}.tar.gz -O mktorrent-${version}.tar.gz
    tar -xf mktorrent-${version}.tar.gz

    ln -s mktorrent-${version} mktorrent
    cd mktorrent-${version}

    make -j 8

    cd ..
}

libowfat() {
    local version="0.33"

    wget https://www.fefe.de/libowfat/libowfat-${version}.tar.xz
    tar -xf libowfat-${version}.tar.xz

    ln -s libowfat-${version} libowfat

    cd libowfat
    make
    cd ..
}

opentracker() {
    git clone git://erdgeist.org/opentracker

    cd opentracker

    sed -i s/'#FEATURES+=-DWANT_V6'/'FEATURES+=-DWANT_V6' Makefile
    make -j 8

    cd ..
}

start() {
    cd opentracker
    # ./opentracker -i ${listen} &
}

network() {
    local version="0.2.3"

    wget https://github.com/threefoldtech/mycelium/releases/download/v${version}/mycelium-x86_64-unknown-linux-musl.tar.gz
    tar -xvf mycelium-x86_64-unknown-linux-musl.tar.gz

    # inspect create the key
    myceladdr=$(./mycelium inspect | grep Address | awk '{ print $2 }')

    # ./mycelium --peers tcp://185.206.122.71:9651 --tun-name ${mycelifname} &

    # myceladdr=$(ip -br a sh dev ${mycelifname} | awk '{ print $3 }' | cut -d/ -f1)
}

create() {
    mkdir -p /tmp/mycelium-torrent
    echo "Hello World" > /tmp/mycelium-torrent/hello

    ./mktorrent/mktorrent -p -a http://[${myceladdr}]:6969/announce -o /tmp/mycelium-demo.torrent /tmp/mycelium-torrent
}

main() {
    cd ${workdir}
    echo "[+] workdir: ${workdir}"

    libowfat
    opentracker
    mktorrent
    network
    create
}

main
