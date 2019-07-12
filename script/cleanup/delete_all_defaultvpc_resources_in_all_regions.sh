#!/usr/bin/env bash
DIR=$(dirname $0)

for region in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
do
    ${DIR}/delete_all_defaultvpc_resources_in_region.sh ${region}
done
