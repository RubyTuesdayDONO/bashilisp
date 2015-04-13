#!/bin/bash -x

declare -a BLI_GLOBAL_ENVIRONMENT=( 'null' one 1 )

bli-debug(){
    echo "DEBUG: ${@}" >&2
}

bli-read(){
    local -a input
    if read -a input
    then
	echo "${input[@]}"
	return 0

	# TODO: not sure we really need to scope input ... 
	re='^(declare -a )(.*)$'
	if [[ $(declare -p BLI_INPUT) =~ $re ]]
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
		bli-debug symbol: "${element}" $( bli-lookup-symbol "${element}" ${environment_name} )
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

for i in {1..1}
do
    echo "> "
    bli-print $(bli-eval 'BLI_GLOBAL_ENVIRONMENT' $(bli-read)) 
done
