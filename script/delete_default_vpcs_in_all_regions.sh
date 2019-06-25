#!/usr/bin/env bash
DIR=$(dirname $0)

for region in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
do
    ${DIR}/delete_default_vpc.sh ${region}
fi
