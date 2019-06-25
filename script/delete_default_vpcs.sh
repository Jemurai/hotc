#!/usr/bin/env bash

function errorCheck {
    if [ $? -eq 0 ]
    then
        echo " done."

        return 0
    else
        echo " error."

        return 1
    fi
}

if [ $# -eq 0 ]
then
    echo "No regions provided"
    echo
    echo "Usage:"
    echo "$0 <region_1> [region_2] ... [region_n]"
    echo

    exit 2
fi

for region in $*
do
    echo "Cleaning region ${region}."

    for vpc in $(aws ec2 describe-vpcs --query "Vpcs[?IsDefault].VpcId" --output text --region ${region})
    do
        for subnet in $(aws ec2 describe-subnets --query "Subnets[?VpcId=='${vpc}'].SubnetId" --output text --region ${region})
        do
            echo -n Deleting subnet: ${subnet}:
            aws ec2 \
                delete-subnet \
                --subnet-id ${subnet} \
                --region ${region}

            errorCheck
        done

        for sg in $(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId=='${vpc}' && GroupName!='default'].GroupId" --output text --region ${region})
        do
            echo -n Deleting security group: ${sg}
            aws ec2 \
                delete-security-group \
                --group-id ${sg} \
                --region ${region}

            errorCheck
        done

        for nacl in $(aws ec2 describe-network-acls --query "NetworkAcls[?VpcId=='${vpc}' && !IsDefault].NetworkAclId" --output text --region ${region})
        do
            echo -n "Deleting network acl ${nacl}:"
            aws ec2 \
                delete-network-acl \
                --network-acl-id ${nacl} \
                --region ${region}
            errorCheck
        done

        for internet_gateway in $(aws ec2 describe-internet-gateways --query "InternetGateways[?Attachments[?VpcId=='${vpc}']].[InternetGatewayId]" --output text --region ${region})
        do
            echo -n Detaching internet gw ${internet_gateway}:
            aws ec2 \
                detach-internet-gateway \
                --vpc-id ${vpc} \
                --internet-gateway-id ${internet_gateway} \
                --region ${region}
            errorCheck

            echo -n "Deleting internet gw ${internet_gateway}:"
            aws ec2 \
                delete-internet-gateway \
                --internet-gateway-id ${internet_gateway} \
                --region ${region}
            errorCheck
        done

        echo -n "Deleting Vpc ${vpc}: "
        aws ec2 \
            delete-vpc \
            --vpc-id ${vpc} \
            --region ${region}
        errorCheck
    done

    echo
done
