#!/bin/bash

bli-debug(){
    return 0;
}

bli-read(){
    local input
    if read input
    then
        bli-debug "read: $input"

        local -a output=();
        local inQueue="$input";
        local -i len="${#input}";
        local -i idx=0;
        local -i inString=0; # are we currently evaluating a string literal?
        local -i inEscape=0; # are we currently evaluating an escape sequence?
        local currString='';
        local currChar='';
        local reStringChunk='^("[^"]*")(.*)$';
        local reTokenChunk='^[[:space:]]*([^[:space:]"]+)(.*$)';
        local reUntermString='^"[^"]*$';
        local reStripOutput='declare [^[:space:]]* output=(.*)$';
        # ( some tokens "and bits" 1 2 345 )

        while (( ${#inQueue} > 0 ))
        do

            if [[ "${inQueue}" =~ $reUntermString ]]
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
                bli-debug "output: ${BASH_REMATCH[1]}"
                output+=("${BASH_REMATCH[1]}");
                inQueue="${BASH_REMATCH[2]}";
                bli-debug "inQueue: $inQueue"
            else
                bli-debug "token check returns: $?"
            fi

        done

        if [[ $(declare -p output) =~ $reStripOutput ]]
        then
            echo "${BASH_REMATCH[1]}"
            return 0;
        else
            echo "FIXME: READ ERROR";
            return 1;
        fi

        return

        # TODO: alternate reader implementation that scans char-by-char vs regex matching
        while (( idx < len ))
        do
            currChar=${input:$idx:1}
            echo read: $currChar
            let idx++
        done
        return 0
        #       echo "${input[@]}"
        #       return 0
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
