# Cleanup Scripts

These scripts are intended to help cleanup AWS resources in unused regions. This is especially helpful when creating a new account. By default, AWS creates VPC resources in every region. Not only do must users not utilize these resources, but they are also not created in a security forward manner. Use the scripts in this directory to remove default (or all) VPC resources in one or more regions.

## Descriptions

| Name | Description |
|------|-------------|
| delete_defaultvpc_resources_in_region.sh | Deletes _all_ *default* VPC resources in a specified region |
| delete_defaultvpc_resources_in_all_regions.sh | Delete _all_ *default* VPC resources in _all_ regions |
| delete_all_vpc_resources_in_region.sh | Delete _all VPC resources_ in the specified region |

## Usage

1. Install AWS CLI tools
1. Configure access for AWS tools. We recommend using [aws-vault](https://github.com/99designs/aws-vault).
1. Run the desired script to perform cleanup.
