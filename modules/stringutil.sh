OBJECT . new STRINGUTIL

if [ "$(echo -e "\\0141")" = a ]; then
        STRINGUTIL . zero =q 0
else
        STRINGUTIL . zero =q ""
fi
chars=' 	
 !"#$%&'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~€ ‚ƒ„…†‡‰‹‘’“”•–—™› ΅Ά£¤¥¦§¨©ª«¬­®―°±²³΄µ¶·ΈΉΊ»Ό½ΎΏΐΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡÒΣΤΥΦΧΨΩΪΫάέήίΰαβγδεζηθικλμνξοπρςστυφχψωϊϋόύώÿ'
STRINGUTIL . chars =q "$chars"

STRINGUTIL . ord : '
# Some chars are special cased, because they have alternate meanings,
# either for us, or for the shell.
#
# <space>	Space is a placeholder for other chars, that can't be
#		part of $chars, for one reason or another.
# *,?		These are wildcards, and inside {}, have special meaning.
# \201,\210	These are only here because ash is not 8-bit clean.

	if [ " " = "$1" ]; then
		echo 32
	elif [ "*" = "$1" ]; then
		echo 42
	elif [ "?" = "$1" ]; then
		echo 63
	elif [ "" = "$1" ]; then
		echo 129
	elif [ "" = "$1" ]; then
		echo 136
	else
		local chars="$($THIS . chars)"
		local left="${chars%%$1*}"
		echo $((${#left}))
	fi
'
STRINGUTIL . chr : '
	local zero=$($THIS . zero)
	echo -e "\\$zero$(( $1 >> 6 ))$(( $1 >> 3 & 7 ))$(( $1 & 7 ))"
'
