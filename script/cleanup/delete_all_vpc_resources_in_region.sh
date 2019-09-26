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
    echo "$0 <region> <vpc_id_1> [[vpc_id_2] [vpc_id_3] ... [vpc_id_n]]"
    echo

    exit 2
fi

REGION=$1
shift

echo "Working in region ${REGION}."
for vpc in $*
do
    echo "Cleaning vpc ${vpc}."
    for subnet in $(aws ec2 describe-subnets --query "Subnets[?VpcId=='${vpc}'].SubnetId" --output text --region ${REGION})
    do
        echo -n Deleting subnet: ${subnet}:
        aws ec2 \
            delete-subnet \
            --subnet-id ${subnet} \
            --region ${REGION}

        errorCheck
    done

    for sg in $(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId=='${vpc}' && GroupName!='default'].GroupId" --output text --region ${REGION})
    do
        echo -n Deleting security group: ${sg}
        aws ec2 \
            delete-security-group \
            --group-id ${sg} \
            --region ${REGION}

        errorCheck
    done

    for nacl in $(aws ec2 describe-network-acls --query "NetworkAcls[?VpcId=='${vpc}' && !IsDefault].NetworkAclId" --output text --region ${REGION})
    do
        echo -n "Deleting network acl ${nacl}:"
        aws ec2 \
            delete-network-acl \
            --network-acl-id ${nacl} \
            --region ${REGION}
        errorCheck
    done

    for internet_gateway in $(aws ec2 describe-internet-gateways --query "InternetGateways[?Attachments[?VpcId=='${vpc}']].[InternetGatewayId]" --output text --region ${REGION})
    do
        echo -n Detaching internet gw ${internet_gateway}:
        aws ec2 \
            detach-internet-gateway \
            --vpc-id ${vpc} \
            --internet-gateway-id ${internet_gateway} \
            --region ${REGION}
        errorCheck

        echo -n "Deleting internet gw ${internet_gateway}:"
        aws ec2 \
            delete-internet-gateway \
            --internet-gateway-id ${internet_gateway} \
            --region ${REGION}
        errorCheck
    done

    echo -n "Deleting Vpc ${vpc}: "
    aws ec2 \
        delete-vpc \
        --vpc-id ${vpc} \
        --region ${REGION}
    errorCheck

    echo
done
