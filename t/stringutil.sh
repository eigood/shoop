#!/bin/sh -e
# Inheritance regression test. Also sets basic methods and variables.
. ${SHOOPSH:-/usr/bin/shoop.sh}
. ${SHOOPMOD:-/usr/share/shoop/modules}/use.sh

OBJECT . use stringutil
STRINGUTIL . new s

# setup

#set -x
# ord/chr
c=1
#set -x
while [ $c -lt 256 ]; do
	char=$(s . chr $c)
	ok "ord-$c($char)" 0 $c	s . ord "$char"
	c=$(( $c + 1 ))
done
tests 255
