#!/bin/bash

source "$(dirname "${0}")/bli-reader.sh"; # read in definitions to test

declare -gi PASS=0;
declare -gi FAIL=1;
declare -gA BLI_TEST_PARAMS=(
    ['null.i']=''
    ['null.e']=''
    ['literal-1.i']='1'
    ['literal-1.e']='1'
);
declare -ga BLI_TESTS=(
    'null'
    'literal-1'
);

debug(){
    return;
    echo "+=== $@:";
    lsof -a -p $$ -d0,1,2,3,4,5,6;
    echo ": $@ ===+";
}

bli-reader.test-suite-build(){
    local re
}

bli-reader.equals-comparator(){
    [[ "${1}" == "${2}" ]];
    return "${?}";
}

bli-reader.matches-comparator(){
    [[ "${1}" =~ ${2} ]];
    return "${?}";
}


bli-reader.test-case(){
    local name="${1}";
    local input="${2}";
    local expected="${3}";
    local comparator="${4:-bli-reader.equals-comparator}";
    local actual="$(bli-read <<<"${input}" )";

    "${comparator}" "${expected}" "${actual}" &&
        {
            echo "PASS: ${name}";
            return "${PASS}";
        } || {
            echo "FAIL: ${name}";
            echo "      input:    /:${input}:\\";
            echo "      expected: /:${expected}:\\";
            echo "      actual:   /:${actual}:\\";
            return "${FAIL}";
        }
    echo "ERROR: UNREACHABLE BRANCH" >&2;
    return 255;
}

bli-reader.test-setup(){
    debug bli-reader.test-setup
    local bliTemp="$(mktemp -d)"
    mkdir -p "${bliTemp}"
    mkfifo "${bliTemp}/"{tests,results}
    eval "${BLI_TEST_FD}<>${bliTemp}/tests"
    eval "${BLI_RESULTS_FD}<>${bliTemp}/results"
    debug bli-reader.test-setup
}

bli-reader.test-print(){
    :
}

e(){ # print rest of args to FD of first arg
    debug e
    local -i fd=$1; shift
    eval "echo $@ >&$fd"
    debug e
}

bli-reader.test-iterator(){
    debug bli-reader.test-iterator
    local -i   testFD="${1}" # output stream for tests
    local -i resultFD="${2}" # output stream for results
    eval "e $testFD some test"
    eval "e $resultFD some result"
    debug bli-reader.test-iterator
}

#bli-reader.test-setup
#bli-reader.test-iterator ${BLI_TEST_FD} ${BLI_RESULTS_FD} ${BLI_RESULTS_FD}>

t(){
    bli-reader.test-case "${@}"
    return "${?}";
}

bli-reader.test-suite(){
    local -i pass=0;
    local -i fail=0;
    local -i threshold="${1:-0}";
    local -i count="${#BLI_TESTS[*]}";
    for (( i=0; i<count; i++ ))
    do
        local name="${BLI_TESTS[$i]}";
        local input="${BLI_TEST_PARAMS[${name}.i]}";
        local expected="${BLI_TEST_PARAMS[${name}.e]}";
        if bli-reader.test-case "${name}" "${input}" "${expected}"
        then
            let pass++;
        else
            let fail++;
        fi
    done

    echo    "+=== TEST RESULTS:";
    echo    "TOTAL:   ${count}"
    echo    "PASS:    ${pass}"
    echo    "FAIL:    ${fail}"
    echo -n "OVERALL: "
    if (( fail>threshold ))
    then
        echo -e "FAIL -__-#\n===+";
        return "${FAIL}";
    else
        echo -e "PASS ^__^!\n===+";
        return "${PASS}";
    fi
}

bli-reader.test-suite-build
bli-reader.test-suite
