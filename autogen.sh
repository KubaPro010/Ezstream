#!/bin/sh

PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/pkg/bin:/usr/pkg/sbin"

_ac_version="2.69"
_am_version="1.15"

if [ ! -f "./$(basename $0)" ]; then
	echo "Please chdir into $(basename $0)'s directory first."
	exit 1
fi

test -n "${AUTOCONF_VERSION}" || AUTOCONF_VERSION="${_ac_version}"
test -n "${AUTOMAKE_VERSION}" || AUTOMAKE_VERSION="${_am_version}"
test -n "${DEFAULT_AUTOCONF}" || DEFAULT_AUTOCONF="${_ac_version}"
export AUTOCONF_VERSION AUTOMAKE_VERSION DEFAULT_AUTOCONF

USE_LIBTOOL="$(grep ^LT_INIT ./configure.* 2> /dev/null)"

EXTRA=
if [ -d m4 ]; then
	EXTRA="-I m4"
fi

if [ -d /usr/local/share/aclocal ]; then
	EXTRA="${EXTRA} -I /usr/local/share/aclocal"
fi

aclocal ${EXTRA} || exit 1
autoconf || exit 1
autoheader || exit 1
if [ -n "${USE_LIBTOOL}" ]; then
	libtoolize --automake -c -f || exit 1
fi
automake -a -c || exit 1

rm -r autom4te.cache

exit 0
