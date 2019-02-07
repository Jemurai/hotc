# Head of the Class

This repo has scripts and terraform to take a brand new AWS account and end with
a good base-line configuration from a security standpoint.

## Steps

Assuming you have a profile configured with Admin rights to the account.

```bash
## Delete all default VPC stuff
./script/delete_default_vpcs.sh

## Create a bucket to store terraform state. Note that Terraform will manage the configuration
## of the bucket, but it needs to exist before we can init terraform.
##
## Be sure to use your selected bucket prefix when creating it.
aws s3api create-bucket <bucket_name_prefix>tfstate --create-bucket-configuration LocationConstraint=<your_preferred_region>

## Now init terraform (passing the newly created bucket name)
cd terraform/global
## Add your bucket prefix to your tfvars file
echo 'bucket_name_prefix = "<bucket_name_prefix>"' > ./terraform.tfvars
terraform init \
    -backend-config bucket=<bucket_name_prefix>tfstate

## Import your tfstate bucket
terraform import aws_s3_bucket.tfstate <bucket_name_prefix>tfstate

## Review the plan
terraform plan

## If everything looks good apply
terraform apply
```
