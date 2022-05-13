#!/usr/bin/env bash
BUCKET=$1
NON_CURRENT_EXPIRE=$2
CURRENT_EXPIRE=$3

if [[ -z "${BUCKET}" ]]
then
    echo "ERROR: Bucket name not provided."
    echo
    echo "USAGE: $0 <non_current_expire_days> [current_expire_days]"
    exit 2
fi

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

echo -n "Checking ${BUCKET}: "
VERSIONING_STATUS=$(aws s3api get-bucket-versioning --bucket ${BUCKET} --query Status --output text)
echo "done"

if [[ "${VERSIONING_STATUS}" = "Enabled" ]]
then
    echo -e "\tVersioning already enabled."
else
    echo -en "\tEnabling versioning: "
    aws s3api put-bucket-versioning \
        --bucket ${BUCKET} \
        --versioning-configuration Status=Enabled
    echo "done"
fi

echo -en "\tLooking for existing lifecycle policy rules: "
aws s3api get-bucket-lifecycle-configuration \
    --bucket ${BUCKET} \
    2>&1 | grep -q NoSuchLifecycleConfiguration

if [[ $? -eq 0 ]]
then
    echo "done."
    echo -en "\tNo lifecycle policy found, creating one: "

    aws s3api put-bucket-lifecycle-configuration \
        --bucket ${BUCKET} \
        --lifecycle-configuration "
        {
            \"Rules\": [
                {
                    \"ID\": \"Expire non-current versions after ${NON_CURRENT_EXPIRE:-7} days \",
                    \"Filter\": {
                        \"Prefix\": \"\"
                    },
                    \"Status\": \"Enabled\",
                    \"Expiration\": {
                        \"ExpiredObjectDeleteMarker\": true
                    },
                    \"NoncurrentVersionExpiration\": {
                        \"NoncurrentDays\": ${NON_CURRENT_EXPIRE:-7}
                    }
                },
                $([[ -n ${CURRENT_EXPIRE} ]] \
                        && echo "
                {
                    \"ID\": \"Expire current versions after ${CURRENT_EXPIRE} days\",
                    \"Filter\": {
                        \"Prefix\": \"\"
                    },
                    \"Status\": \"Enabled\",
                    \"Expiration\": {
                        \"Days\": ${CURRENT_EXPIRE}
                    },
                },")

                {
                    \"ID\": \"Abort incomplete multiple uploads after 1 day\",
                    \"Status\": \"Enabled\",
                    \"Filter\": {
                        \"Prefix\": \"\"
                    },
                    \"AbortIncompleteMultipartUpload\": {
                        \"DaysAfterInitiation\": 1
                    }
                }
            ]
        }"

        echo "done."
else
    echo -e "found.\n\tExisting lifecycle policy rules found. Will not replace. Verify lifecycle rules manually."
fi
