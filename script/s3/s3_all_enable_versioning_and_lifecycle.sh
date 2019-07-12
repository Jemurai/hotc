#!/usr/bin/env bash
NON_CURRENT_EXPIRE=$1
CURRENT_EXPIRE=$2

if [[ -z "${NON_CURRENT_EXPIRE}" ]]
then
    echo "ERROR: Expiration days for non-current versions was not provided."
    echo
    echo "USAGE: $0 <non_current_expire_days> [current_expire_days]"
    exit 1
fi

aws s3api list-buckets --query 'Buckets[].Name' | jq -r '.[]' |\
    while read BUCKET
    do
        echo -n "Checking ${BUCKET}: "
        VERSIONING_STATUS=$(aws s3api get-bucket-versioning --bucket ${BUCKET} --query Status --output text)
        echo "done"

        if [[ "${VERSIONING_STATUS}" = "Enabled" ]]
        then
            echo -e "\tVersioning already enabled."
        else
            echo -en "\tEnabling versioning: "
            aws s3api put-bucket-versioning \
                --bucket ${BUCKET}
                --versioning-configuration Status=Enabled
            echo "done"
        fi

        echo -en "\tLooking for existing lifecycle policy rules: "
        aws s3api get-bucket-lifecycle-configuration \
            --bucket ${BUCKET} \
            2>&1 | grep -q NoSuchLifecycleConfiguration

        if [[ $? -ne 0 ]]
        then
            echo "done."
            echo -en "\tNo lifecycle policy found, creating one: "

            aws s3api put-bucket-lifecycle-configuration \
                --bucket ${BUCKET} \
                --lifecycle-configuration "
                {
                    \"Rules\": [
                        {
                            \"ID\": \"Delete expired s3 server access logs\",
                            \"Prefix\": \"s3/\",
                            \"Status\": \"Enabled\",
                            $([[ -n ${CURRENT_EXPIRE} ]] \
                                && echo "
                                \"Expiration\": {
                                    \"Days\": ${CURRENT_EXPIRE}
                                },"
                             )
                            \"NoncurrentVersionExpiration\": {
                                \"NoncurrentDays\": ${NON_CURRENT_EXPIRE:-7}
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
        else
            echo -e "found.\tExisting lifecycle policy rules found. Will not replace. Verify lifecycle rules manually."
        fi
    done
