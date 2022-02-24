#!/bin/sh

set -eu

# https://stackoverflow.com/questions/29613304/is-it-possible-to-escape-regex-metacharacters-reliably-with-sed/29626460#29626460
program_escaped=$(sed 's/[^^\\]/[&]/g; s/\^/\\^/g; s/\\/\\\\/g' <<<"${program}")
sed_regex1="s/${program_escaped}(\(.*\)+0x[[:xdigit:]]*)[0x[[:xdigit:]]*]/\1/p"
sed_regex2='s/^\(.*\)_[[:digit:]]*$/\1/'

sed -n -e "${sed_regex1}" | sed -e "${sed_regex2}"
