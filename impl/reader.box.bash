#!/bin/bash

# cells:  value, function
# values: atom, cons
# atom:   symbol, number, string


model-cell(){
    let cell="${1}"
    case "${cell}" in
	'value')
}

cell-symbol-foo(){
    let cell="${1}"
    case "${cell}" in
	'value')
	    echo 'foo'
	    ;;
    esac
}

cell-string-abcdefg(){
    let cell="${1}"
    case "${cell}" in
	'value')
	    echo '"abcdefg"'
	    ;;
    esac
}

cell-number-12345(){
    let cell="${1}"
    case "${cell}" in
	'value')
	    echo '12345'
	    ;;
    esac
}

cell-number-12345(){
    let cell="${1}"
    case "${cell}" in
	'value')
	    echo '12345'
	    ;;
    esac
}
