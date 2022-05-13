#!/usr/bin/env bash

aws s3api list-buckets --query 'Buckets[].Name' | jq -r '.[]' |\
    while read BUCKET
    do
        SSEAlgo=$(aws s3api get-bucket-encryption --bucket $BUCKET --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.[SSEAlgorithm]' --output text 2>/dev/null)

        if [[ $? -ne 0 ]]
        then
            echo "${BUCKET} does not have SSE enabled"
            echo -en "\tAttempting to enable: "
            aws s3api put-bucket-encryption --bucket $BUCKET --server-side-encryption-configuration '
            {
                "Rules": [
                    {
                        "ApplyServerSideEncryptionByDefault": {
                            "SSEAlgorithm": "AES256"
                        }
                    }
                ]
            }' 2>&1 > /dev/null

            if [[ $? -eq 0 ]]
            then
                echo "Success"
            else
                echo "Failed"
            fi
        else
            echo "${BUCKET} already has encryption configuration: ${SSEAlgo}"
        fi
    done
