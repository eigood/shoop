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
