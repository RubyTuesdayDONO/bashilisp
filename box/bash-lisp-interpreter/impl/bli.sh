#!/bin/bash -x

bli-read(){
    local input
    read input
    echo "BLI_READ='$input'"
    }

bli-read
