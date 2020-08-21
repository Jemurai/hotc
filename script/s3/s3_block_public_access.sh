#!/usr/bin/env bash
BUCKET=$1
REGION=$2

if [[ -z "${BUCKET}" ]]
then
    echo "ERROR: bucket name not provided"
    echo
    echo "Usage: $0 <bucket_name>"
    exit 1
fi

if [[ -n "${REGION}" ]]
then
    REGION_PARAM="--region ${REGION}"
fi

aws s3api get-public-access-block --bucket ${BUCKET} ${REGION_PARAM}

if [[ $? ]]
then
    echo "Bucket already has a public access block enabled"
else
    echo -n "Enabling public access block for bucket ${BUCKET}: "
    aws s3api put-public-access-block \
        --bucket ${BUCKET} \
        ${REGION_PARAM} \
        --public-access-block-configuration '
        {
            "BlockPublicAcls": true,
            "IgnorePublicAcls": true,
            "BlockPublicPolicy": true,
            "RestrictPublicBuckets": true
        }'

    if [[ $? ]]
    then
        echo "successful."
    else
        echo "failed."
    fi
fi
