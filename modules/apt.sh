OBJECT . new APT

APT . methoddir =q /usr/lib/apt/methods
APT . fetch : '
	local method=$1 uri file aptmethod counter entity; shift
	aptmethod=$($THIS . methoddir)/$method
	if [ ! -x $aptmethod ]; then
		echo "Method \`$method\` not found!"
		return 1
	fi
	while [ $# -gt 0 ]; do
		counter=$(($counter + 1))		
		local fetch_uri_$counter="$1" fetch_file_$counter="$2"
		shift 2
		entity="$entity $counter"
	done
	(cat << _EOF_
601 Configuation
Config-Item: Debug::Acquire::http=true

_EOF_
	for a in $entity; do
		eval uri=\$fetch_uri_$a file=\$fetch_file_$a
		rm -f $file
		cat << _EOF_
600 URI Acquire
URI: $uri
Filename: $file

_EOF_
		sleep 1
	done) |
	(
		while read; do
			echo "to method [$REPLY]" >&2
			echo "$REPLY"
		done
	) |
	($aptmethod; echo -e "999 Method done\nExit-Status: $?")|
	(
		while read; do
			echo "from method {$REPLY}" >&2
			if [ "$inmsg" ]; then
				:
			else
				:
			fi
		done
	)
	echo $?
	wait
'
