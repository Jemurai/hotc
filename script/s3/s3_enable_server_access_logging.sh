#!/usr/bin/env bash

TARGET_BUCKET=$1
SOURCE_BUCKET=$2
TARGET_PREFIX=$3

if [[ -z "${TARGET_BUCKET}" ]] || [[ -z "${SOURCE_BUCKET}" ]]
then
  echo "ERROR: source and/or target bucket name not provided"
  echo
  echo "Usage: $0 <target_bucket> <source_bucket> [target_prefix]"
  echo
  echo -e "\ttarget_bucket:\tName of the bucket to which logs should be written"
  echo -e "\tsource_bucket:\tName of the bucket on which server logs should be enabled"
  echo -e "\ttarget_prefix:\tPrefix at which logs should be stored (defaults to access-logs/s3/<source_bucket>"

  exit 1
fi

if [[ -n $(aws s3api get-bucket-logging --bucket ${SOURCE_BUCKET}) ]]
then
  echo "${SOURCE_BUCKET} already has server access logging enabled. Please verify configuration manually"
else
  echo -n "Configuring server access logging for bucket ${SOURCE_BUCKET}: "
  aws s3api put-bucket-logging \
      --bucket ${SOURCE_BUCKET} \
      --bucket-logging-status "
       {
         \"LoggingEnabled\": {
           \"TargetBucket\": \"${TARGET_BUCKET}\",
           \"TargetPrefix\": \"${TARGET_PREFIX:-access-logs/s3/${SOURCE_BUCKET}/}\"
         }
       }"

  if [[ $? ]]
  then
    echo "successful."
  else
    echo "failed."
  fi
fi
