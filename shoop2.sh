#!/bin/sh -e
SHOOP() {
	class() {
		local class=$1; shift
		if eval [ \"\$_shoopclass_$class\" ]; then
			echo "Class already defined!($class)" >&2
			return 1
		fi
		eval _shoopclass_$class=1
		_shoop_class_stack="$class $_shoop_class_stack"
		_shoop_current_class=$class
		_shoop_location=class
		_shoopforward="${_shoopforward:+${_shoopforward}_}$class"
		_shoopreverse="$class${_shoopreverse:+_$_shoopreverse}"
		if [ "$1" = : ]; then
			shift
			eval "_shoopparents_$class=\"\$@\""
		fi
	}
	_part() {
		local type=$1 name=$2; shift 2
		if eval [ \"\$_shooptype_${_shoop_current_class}_$name\" ]; then
			echo "Name already defined!($_shoop_current_class.$name)" >&2
			return 1
		fi
		eval "_shoopflags_${_shoop_current_class}_$name=$flags\
		      _shooptype_${_shoop_current_class}_$name=$type\
		      _shoopparts_${_shoop_current_class}=\"\${_shoopparts_${_shoop_current_class}:+\$_shoopparts_${_shoop_current_class} }$name\""
		if [ ! -z "$@" ]; then
			if [ $type = variable ]; then
				if [ $1 != = ]; then
					echo "Syntax error!  \`$1' not allowed."
					return 1
				fi
				shift
				eval "_shoop_${_shoopforward}_$name=\"echo -n '$@'\""
			else
				eval "_shoop_${_shoopforward}_$name=\"\$@\""
			fi
		fi
	}
	end() {
		local IFS="_ "
		case "$_shoop_location" in
			class)
				set -- $_shoop_class_stack
				shift
				_shoop_class_stack="$@"
				_shooptest="${_shooptest}_$1"
				set -- $_shoopreverse
				current_class="$1"
				shift
				if [ "$_shoopreverse" = "$current_class" ]; then
					_shoopreverse=
				else
					_shoopreverse=${_shoopreverse#${current_class}_}
				fi
				if [ "$_shoopforward" = "$current_class" ]; then
					_shoopforward=
				else
					_shoopforward=${_shoopforward%_${current_class}}
				fi
			;;
			method)
				set -- $_shoop_method_stack
				shift
				_shoop_method_stack="$@"
			;;
		esac
	}
	_resolve() {
		local class parent parents methods;
		while [ $# -gt 0 ]; do
			class=$1
			if eval [ \"\$_shoopresolved_$class\" ]; then
				continue;
			fi
			eval "parents=\$_shoopparents_$class"
			if [ "$parents" ]; then
				resolve $parents
			fi
			for parent in $parents; do
				eval methods=${methods:-$methods }\$_shoop
			done
			shift
		done
	}
	new() {
		local name=$1 cmd=$2 THIS=$1 class=$3; shift 2
		if [ "$cmd" != ":" ]; then
			echo "Syntax error in new.($name $cmd $@)" >&2
			return 1
		fi
		if eval [ -z \"\$_shoopresolved_$class\" ]; then
			_resolve "$@"
		fi
		if eval [ -z \"\$_shoopclass_$class\" ]; then
			echo "$class not defined!" >&2
			return 1
		fi
		if eval [ \"\$_shoopdata_${class}_$class\" ];then
			eval eval \$_shoopdata_${class}_$class
		fi
		eval _shoop_${name}_parent=\"echo -n '$@'\"
		eval $name\(\) \{ local cmd=\"\$1\"\; shift\; _shoop $cmd $name $name '"$@"' \; \}
	}
	local abstract public flags
	while :; do
		case "$1" in
			abstract|public)
				eval $1=1
				flags="${flags:+$flags }$1"
			;;
			*)
				break
			;;
		esac
		shift
	done
	case "$1" in
		method|variable)
			_part "$@"
		;;
		class|end|new)
			"$@"
		;;
		*)
			echo "Unknown SHOOP command($1)!"
			exit 1
		;;
	esac
}
_shoop2() {
	local cmd=$1 object=$2 class=$3 THIS=$2 entity=$4 type; shift 4
	eval type=\$_shooptype_${class}_$entity
	if eval [ "$type" = variable ]; then
		if [ "$1" = = ]; then
			shift;
			eval "_shoop_${object}_$entity=\"$@\""
			return 0
		elif eval [ -z \"\$_shoop_${object}_$entity\" ]; then
			eval "_shoop_${object}_$entity=\"\$_shoopdata_${class}_$entity\""
		fi
		eval echo -n \"\$_shoop_${object}_$entity\"
	else
		eval eval \$_shoop_${class}_$entity
	fi
}
