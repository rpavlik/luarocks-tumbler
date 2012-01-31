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
logfile="${rundir}/tumbler.log"
logappend="tee -a '${logfile}'"

touch "${logfile}"

if [ $# -eq 0 ]; then
	rockdirs="${rundir}"
else
	rockdirs="$@"
fi

temps=""

: ${TREEDIR:="${rundir}/tree"}
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

(
	# Grab latest luarocks and install
	cd "${WORKDIR}"
	if [ ! -f luarocks-${luarocks_ver}.tar.gz ]; then
		$WGET $luarocks_url
		tar xvzf luarocks-${luarocks_ver}.tar.gz | ${logappend}
	fi
	cd luarocks-$luarocks_ver
	./configure --prefix=${PREFIX} --sysconfdir=${TREEDIR} --rocks-tree=${TREEDIR} --force-config  | ${logappend}
	make install | ${logappend}
)

for rockdir in ${rockdirs}; do
(
	cd ${rundir}
	cd ${rockdir}
	${PREFIX}/bin/luarocks make | ${logappend}
)
done
