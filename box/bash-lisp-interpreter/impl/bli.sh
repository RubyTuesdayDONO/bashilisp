#!/bin/bash -x

declare -a BLI_GLOBAL_ENVIRONMENT=( 'null' one 1 )

bli-debug(){
    echo "DEBUG: ${@}" >&2
}

bli-read(){
    local input
    if read input
    then
	bli-debug "read: $input"

	local -a output
	local inQueue="$input"
	local -i len="${#input}"
	local -i idx=0
	local -i inString=0 # are we currently evaluating a string literal?
	local -i inEscape=0 # are we currently evaluating an escape sequence?
	local currString=''
	local currChar=''
	local reStringChunk='^("[^"]*")(.*)$'
	local reTokenChunk='^[[:space:]]*([^[:space:]"]+)(.*$)'
	local reUntermString='^"[^"]*$'

	# ( some tokens "and bits" 1 2 345 )

	while (( ${#inQueue} > 0 ))
	do

	    if [[ "$inQueue" =~ $reUntermString ]]
	    then
		bli-debug "read error: unterminated string: $inQueue"
		return 1
	    else
		bli-debug "unterminated string check returns: $?"
	    fi

	    if [[ "$inQueue" =~ $reStringChunk ]]
	    then
		output += "${BASH_REMATCH[1]}"
		inQueue="${BASH_REMATCH[2]}"
	    else
		bli-debug "string check returns: $?"
	    fi

	    if [[ "$inQueue" =~ $reTokenChunk ]]
	    then
		bli-debug "reTokenChunk: ${BASH_REMATCH[1]}"
		inQueue="${BASH_REMATCH[2]}"
		bli-debug "inQueue: $inQueue"
	    else
		bli-debug "token check returns: $?"
	    fi

	done
	
	return
	while (( idx < len ))
	do
	    currChar=${input:$idx:1}
	    echo read: $currChar
	    let idx++
	done
	return 0
#	echo "${input[@]}"
#	return 0
	# TODO: not sure we really need to scope input ... 
	re="^(declare -a input='\\()(.*)\\)'\$"
	if [[ $(declare -p input) =~ $re ]]
	then
	    echo "${BASH_REMATCH[2]}"
	fi
       return 0
    else
	return 1
    fi
}

bli-eval(){
    local environment_name="${1}"; shift
    for element in ${@}
    do
	if bli-self-evaluating-p "${element}"
	then
	    bli-debug self-evaluating: "${element}"
	    echo "${element}" 
	else
	    if bli-symbol-p "${element}"
	    then
		bli-debug symbol: "${element}"
		bli-lookup-symbol "${element}" ${environment_name}
	    fi
	fi
    done
}

bli-print(){
    local input=( $@ )
    echo $input
}

bli-self-evaluating-p(){
    local reIntLiteral='[0-9]+'
    local reStringLiteral='"[^"]+"'
    local reLiteral="^(${reIntLiteral}|${reStringLiteral})$"
    local input="${1}"
    if [[ "${input}" =~ $reLiteral ]]
    then
	return 0
    else
	return 1
    fi
}

bli-symbol-p(){
    local reSymbol='^[[:alnum:]_+-]+$'
    local input="${1}"

    if [[ "${input}" =~ $reSymbol ]]
    then
	return 0
    else
	return 1
    fi
}

bli-lookup-symbol(){
    local symbol="${1}"
    local envName="${2}"
    bli-debug ${!envName[@]}
    eval "environment=( ${!envName} )"
    eval local environment=( ${envName[@]} )
    local parent="${environment[0]}"
    environment="${environment[@]:1:}"
    
    #bli-debug "${0}: $@ $#"
    eval local -a environment=( "$@" )
    while (( $# > 0 ))
    do
	local key="${1}"; shift
	if (( $# > 0 ))
	then
	    if [[ "${key}" == "${symbol}" ]]
	    then
		echo "${1}"
		return 0
	    else
		shift
	    fi
	fi
    done

    if [[ -z "${parent}" ]] || [[ "${parent}" == 'null' ]]
    then
	bli-debug "symbol ${symbol} not found"
	return 1
    else
	bli-lookup-symbol "${symbol}" "${parent}" ${environment[@]}
	return $?
    fi
}

bli-test(){
    echo bli-test'!'
}

bli-read-test(){
    bli-read <<EOF
( some tokens "and bits" 1 2 345 )
some more tokens
    leading whitespace
"unterminated string
EOF
}

while read -a command
do
      eval ${command[@]}
done

exit


for i in {1..1}
do
    echo "> "
    bli-print $(bli-eval 'BLI_GLOBAL_ENVIRONMENT' $(bli-read)) 
done

