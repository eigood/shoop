#!/bin/sh -e

# LGPL copyright 2000 by Adam Heath <doogie@debian.org>

## Creates a new WWW object.  C<WWW . fetch>(a simplistic wrapper around
## wget) expects a list of (I<url> I<file>) pairs.  C<WWW . finished>
## checks the passed filename to see if it has I<E<lt>/htmlE<gt>> in it,
## which should mean the page was built properly.  This is used to
## detect errors in dynamically generated pages.

OBJECT . new WWW

WWW . fetch : '
	local url file output return
	while [ $# -gt 0 ]; do
		url="$1" file="$2"; shift 2
		if [ "$file" ]; then
			file="-O $file"
		fi
		if ! wget -q $file $url 2>&1; then
			return 1
		fi
	done
'

WWW . finished : '
	local tmp=${2:-$($THIS . tmpfile1)} return
	$THIS . fetch $1 $tmp
	if ! grep -qi "</html>" $tmp; then
		return 1
	fi
'
