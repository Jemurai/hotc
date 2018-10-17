# Introduction

This folder is contains the basic terraform needed to establish a baseline working setup. This does not do anything to improve the security of your environment.

## Setup

Before you get started with Terraform, you will need to create a bucket for storing terraform state. This only needs to be done once and can be managed by Terraform after it is established.

```sh
λ aws s3 mb s3://yournamehere-tfstate
```

This will create a basic S3 bucket. Don't worry about the additional arguments as the Terraform code that follows will make the appropriate changes.

## Execution

Make sure you have Terraform installed and available on your command line and execute the following:

```sh
λ terraform init
```

This will download the AWS provider module for Terraform and setup the initial state file. Before we apply our changes we need to import the bucket we created into Terraform. This is a small bootstrapping issue that we need to address due to how Terraform handles the `backend` section when it loads. This phase is performed to early to resolve and correct issues, so the bucket we use needs to already be available for the rest of our code to execute.

```sh
terraform import aws_s3_bucket.yournamehere-tfstate yournamehere-tfstate
```

Once this completes we can apply our changes:

```sh
λ terraform apply
```

Answer `yes` when prompted. If this completes with no errors you are ready to move to one of the corrective sections of this project.