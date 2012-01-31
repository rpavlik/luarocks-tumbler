#!/bin/bash

luarocks_ver="2.0.7.1"
luarocks_url="http://luarocks.org/releases/luarocks-${luarocks_ver}.tar.gz"

if which wget > /dev/null; then
	WGET="wget -c -t0"
else
	WGET="curl -O --retry 10"
fi

rundir=$(pwd)
scriptdir=$(cd $(dirname $0) && pwd)

temps=""

: ${TREEDIR:="${rundir}/tree"
mkdir -p "${TREEDIR}"

if [ -z "${PREFIX}" ]; then
	PREFIX=$(mktemp -d)
	temps="${temps} ${PREFIX}"
fi
mkdir -p "${WORKDIR}"

if [ -z "${WORKDIR}" ]; then
	WORKDIR=$(mktemp -d)
	temps="${temps} ${WORKDIR}"
fi
mkdir -p "${WORKDIR}"

trap "rm -rf $temps" EXIT

# Grab latest luarocks
cd "${WORKDIR}"
$WGET $luarocks_url
tar xvzf luarocks-${luarocks_ver}.tar.gz
cd luarocks-$LUAROCKS_VERSION
