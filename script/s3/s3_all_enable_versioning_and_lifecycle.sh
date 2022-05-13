#!/usr/bin/env bash
NON_CURRENT_EXPIRE=$1
CURRENT_EXPIRE=$2

if [[ -z "${NON_CURRENT_EXPIRE}" ]]
then
    echo "WARN: No non-current expiration provided. The default of 7 days will be used."
    echo
    read -p "Continue? " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo
        echo "Halting."
        exit 1
    fi
fi

aws s3api list-buckets --query 'Buckets[].Name' | jq -r '.[]' |\
    while read BUCKET
    do
        ./s3_enable_versioning_and_lifecycle.sh ${BUCKET} ${NON_CURRENT_EXPIRE} ${CURRENT_EXPIRE}
    done
