#!/bin/bash

#MIT License
#
#Copyright (c) 2022 Nathan McGarvey
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

usage() { echo "Usage: $0 [-d] [-e <excluded characters>] [-i <required characters>] [-l <length of word>] [-p <addtional GREP pattern>]" 1>&2; exit 1; }

#Defaults before arguments
exclude_letters='.'
require_letters=''
additional_grep_pattern='.'
duplicate_letters=1
length=5

while getopts "de:i:l:p:" o; do
    case "${o}" in
        d)
            duplicate_letters=0;
            ;;
        e)
            exclude_letters="${OPTARG}"
            ;;
        i)
            require_letters="${OPTARG}"
            ;;
        l)
            length="${OPTARG}"
            ;;
        p)
            additional_grep_pattern="${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


#Just make a wordlist array... you can put whatever you want here
readarray -t words < <(grep -E "^[a-zA-Z]{${length}}\$" /usr/share/dict/words | iconv -f utf8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]' | grep "$additional_grep_pattern" | grep -vi "[${exclude_letters}]" | sort -u)

for (( i=0; i<${#require_letters}; i++ )); do
    require_letter="${require_letters:$i:1}"
    echo "Requiring '$require_letter' to be present" >&2
    readarray -t words_new < <(printf "%s\n" "${words[@]}" | grep -F "${require_letter}")

#echo "${require_letter}"
#echo "OLD: ${words[@]}"
#echo "NEW: ${words_new[@]}"
#echo
    words=("${words_new[@]}")

done

#Associative arrays require BaSH 4.X+
declare -A alpha_counts=( [a]=0 [b]=0 [c]=0 [d]=0 [e]=0 [f]=0 [g]=0 [h]=0 [i]=0 [j]=0 [k]=0 [l]=0 [m]=0 [n]=0 [o]=0 [p]=0 [q]=0 [r]=0 [s]=0 [t]=0 [u]=0 [v]=0 [w]=0 [x]=0 [y]=0 [z]=0 );

#Actually remove excluded letters from our metrics gathering
for (( i=0; i<${#exclude_letters}; i++ )); do
    exclude_letter="${exclude_letters:$i:1}"
    echo "Removing '$exclude_letter' from the possible letters" >&2
    unset alpha_counts["$exclude_letter"]
done


echo "Number of letters tested: ${#alpha_counts[@]}" >&2
echo "Letters tested: ${!alpha_counts[*]}" >&2

echo "Number of words: ${#words[@]}" >&2

#Score the letters by commonality
for alpha in "${!alpha_counts[@]}"; do
echo "Scanning letter '$alpha'..." >&2
    for w in "${words[@]}"; do
        if [[ "$w" == *"$alpha"* ]]; then
            res_count=1
            if [[ $duplicate_letters -gt 0 ]]; then
              res="${w//[^${alpha}]}"
              res_count="${#res}"
            fi
            ((alpha_counts["$alpha"]+=res_count))
        fi
    done
done

echo 'Character counts:' >&2
for alpha in "${!alpha_counts[@]}"; do
    echo "${alpha_counts[$alpha]}" "$alpha"
done | sort -rn >&2


echo 'Searching for most-likely to hit word:'
for w in "${words[@]}"; do
    score=0
    word="$w"
    if [[ $duplicate_letters -eq 0 ]]; then
        word="$(grep -Eo '.{1}' <<< "$word" | sort -u | paste -s -d '')"
    fi
    for (( i=0; i<${#word}; i++ )); do
        ((score+=alpha_counts["${word:$i:1}"]))
    done
    echo "${w} (${word}): ${score}"
done | sort -k3n
