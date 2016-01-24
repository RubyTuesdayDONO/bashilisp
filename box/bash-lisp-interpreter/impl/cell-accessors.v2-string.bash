#!/bin/bash


cell-is-pair(){
    local cell="${!1}"
    [[ "${cell:0:1}" == 'p' ]] # && return 0 || return 1
}

cell-is-atom(){
    local cell="${!1}"
    [[ "${cell:0:1}" == 'a' ]] # && return 0 || return 1
}

cell-is-function(){
    local cell="${!1}"
    [[ "${cell:0:1}" == 'f' ]] # && return 0 || return 1
}

cell-read-string(){
    local cell="${!1}"
    [[ "${cell:0:2}" == 'as' ]] && printf '%s\0' "${cell:2}" && return 0
}

