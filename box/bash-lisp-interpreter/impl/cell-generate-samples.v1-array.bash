#!/bin/bash -e

# Cells: cell type, car / atom type / function environment, cdr / atom value / function definition (name)
# Cell Types: atom (a), pair (p), function (f)
# Atom Types: symbol (n), string (s), integer (i), float (f), nil (0)
# Car/Cdr: name of contained cell
# Atom Value: bash literal 

cat <<EOF
declare -a cells

f-12345(){
    printf "%s completed normally" "$(basename "${0}")"
    return 0
}

EOF


for (( i=1; i<1000; i++ ))
do
    printf -v a1 "%09d_%05d" "${i}" "${RANDOM}"
    printf -v a2 "%09d_%05d" "${i}" "${RANDOM}"
    printf -v a3 "%09d_%05d" "${i}" "${RANDOM}"
    printf -v a4 "%09d_%05d" "${i}" "${RANDOM}"
    printf -v a5 "%09d_%05d" "${i}" "${RANDOM}"
    printf -v a6 "%09d_%05d" "${i}" "${RANDOM}"
    printf -v a7 "%09d_%05d" "${i}" "${RANDOM}"

    cat <<EOF
cells+=( 'c_${a1}' 'c_${a2}' 'c_${a3}' 'c_${a4}' 'c_${a5}' 'c_${a6}' 'c_${a7}' )
EOF

    printf "c_%s=( 'a' 'n' 'foo' )\n" "${a1}"
    printf "c_%s=( 'a' 's' 'hello, world!' )\n" "${a2}"
    printf "c_%s=( 'a' 'i' '%d' )\n" "${a3}" "${RANDOM}"
    printf "c_%s=( 'a' 'f' '%d.%d' )\n" "${a4}" "${RANDOM}" "${RANDOM}"

    printf "c_%s=( 'p' 'c-%s' 'c-%s' )\n" "${a5}" "${a1}" "${a2}"
    printf "c_%s=( 'p' 'c-%s' 'c-%s' )\n" "${a6}" "${a1}" '0'
    printf "c_%s=( 'p' 'c-%s' 'c-%s' )\n" "${a7}" "${RANDOM}" "${a6}"
    printf "c_%s=( 'f' 'a=\"%d\" b=\"%d\" c=\"%d\"' 'f-12345' )\n" "${a7}" "${RANDOM}" "${RANDOM}" "${RANDOM}"

done

