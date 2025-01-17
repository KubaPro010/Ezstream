#!/bin/sh

# ezstream-file.sh
# Convenience/wrapper script that uses ezstream to stream one or more files
# given on the command line.

# Copyright (c) 2009, 2015 Moritz Grimm <mgrimm@mrsserver.net>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

_myname="$(basename $0)"
_filename_placeholder="%FILENAME%"

_opt_string="hp:qrT:Vv"
print_usage()
{
	echo "usage: ${_myname} [-hqrVv] [-T cfg_template] [file ...]" >&2
}

print_usage_help()
{
	cat << __EOT >&2

  -h           print this help and exit
  -p pidfile   [ezstream] write PID to pidfile
  -q           [ezstream] suppress STDERR output from external en-/decoders
  -r           [ezstream] show real-time stream information on stdout
  -T template  run ezstream using template for configuration
  -V           print the version number and exit
  -v           [ezstream] increase logging verbosity

The configuration template must contain the configuration statement
        <filename>${_filename_placeholder}</filename>
inside the <media /> block.

See the ezstream-file.sh(1) manual for detailed information.
__EOT
}

_pidfile=""
_pidfile_arg=""
_quiet=""
_rtstatus=""
_verbose=""
_cfg_template="${EZSTREAM_TEMPLATE}"

_args=`getopt ${_opt_string} $*`
if [ $? -ne 0 ]; then
	print_usage
	exit 2
fi
set -- ${_args}
while [ $# -ge 0 ]
do
	case "$1" in
	-h)
		print_usage
		print_usage_help
		exit 0
		;;
	-p)
		_pidfile="-p"
		_pidfile_arg="$2"
		shift; shift ;;
	-q)
		_quiet="-q"; shift ;;
	-r)
		_rtstatus="-r"; shift ;;
	-T)
		_cfg_template="$2"; shift; shift ;;
	-V)
		echo "${_myname} 1.1.0"
		exit 0
		;;
	-v)
		if [ -z "${_verbose}" ]; then
			_verbose="-v"
		else
			_verbose="${_verbose}v"
		fi
		shift ;;
	--)
		shift; break ;;
	esac
done

if [ -z "${_cfg_template}" ]; then
	echo "${_myname}: No configuration template supplied." >&2
	echo "Use -T or the EZSTREAM_TEMPLATE environment variable." >&2
	exit 2
fi
if [ ! -e "${_cfg_template}" ]; then
	echo "${_myname}: Configuration template ${_cfg_template} does not exist." >&2
	exit 2
fi
if [ -z "$(grep ${_filename_placeholder} ${_cfg_template})" ]; then
	echo "${_myname}: ${_cfg_template} lacks the ${_filename_placeholder} placeholder." >&2
	exit 2
fi

test -n "${EZSTREAM}" || EZSTREAM="$(which ezstream)"
if [ -z "${EZSTREAM}" ]; then
	echo "${_myname}: Cannot find ezstream." >&2
	exit 2
fi

_temp_dir="`mktemp -t -d _ezstream.XXXXXXXXXX`"
if [ $? -ne 0 ]; then
	echo "${_myname}: Unable to create temporary directory." >&2
	exit 1
fi
trap 'rm -rf ${_temp_dir}' 0
trap 'rm -rf ${_temp_dir}; exit 1' 2 15

_cfg="${_temp_dir}/config.xml"
_playlist="${_temp_dir}/playlist.txt"

touch "${_cfg}" || exit 1
chmod 0600 "${_cfg}" || exit 1

sed -e "s,${_filename_placeholder},${_playlist},g" \
	< "${_cfg_template}" \
	> "${_cfg}"
if [ $? -ne 0 ]; then
	echo "${_myname}: Unable to create configuration." >&2
	exit 1
fi

if [ -n "$1" ]; then
	for _file in $*
	do
		echo "${_file}" >> "${_playlist}"
	done
else
	while read _file
	do
		echo "${_file}" >> "${_playlist}"
	done
fi

${EZSTREAM} ${_quiet} ${_rtstatus} ${_verbose} ${_pidfile} ${_pidfile_arg} \
    -c "${_cfg}"

exit $?
