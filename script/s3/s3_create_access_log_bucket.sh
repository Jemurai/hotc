#!/usr/bin/env bash
BUCKET=$1
REGION=$2
PRIMARY_LOG_RETENTION=$3
SECONARY_LOG_RETENTION=$4

if [[ -z "${BUCKET}" ]]
then
    echo "ERROR: name of bucket must be provided on CLI"
    echo "USAGE: $0 <bucket_name>"
    exit 1
fi

if [[ -n "${REGION}" ]]
then
    REGION_PARAM="--region ${REGION}"
    BUCKET_CONFIG="--create-bucket-configuration LocationConstraint=${REGION}"
fi

aws s3api create-bucket \
    --bucket ${BUCKET} \
    --acl private \
    ${REGION_PARAM} ${BUCKET_CONFIG}

if [[ $? -ne 0 ]]
then
    echo "Error creating the bucket. Perhaps that name is already taken"
    exit 2
fi

echo -n "Waiting for bucket creation to complete: "
sleep 2
echo "done."

aws s3api put-public-access-block \
    --bucket ${BUCKET} \
    --public-access-block-configuration '
    {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'

aws s3api put-bucket-acl  \
    --bucket ${BUCKET} \
    --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery \
    --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery

echo "Enabling versioning"
aws s3api put-bucket-versioning \
    --bucket ${BUCKET}
    --versioning-configuration Status=Enabled

aws s3api put-bucket-lifecycle-configuration \
    --bucket ${BUCKET} \
    --lifecycle-configuration "
    {
        \"Rules\": [
            {
                \"ID\": \"Delete expired s3 server access logs\",
                \"Prefix\": \"s3/\",
                \"Status\": \"Enabled\",
                \"Expiration\": {
                    \"Days\": ${LOG_RETENTION:-365}
                },
                \"NoncurrentVersionExpiration\": {
                    \"NoncurrentDays\": ${LOG_RETENTION:-7}
                }
            },

            {
                \"ID\": \"Abort incomplete multiple uploads after 1 day\",
                \"Status\": \"Enabled\",
                \"Prefix\": \"\",
                \"AbortIncompleteMultipartUpload\": {
                    \"DaysAfterInitiation\": 1
                }
            }
        ]
    }"
