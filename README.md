# VPC with public subnet using Cloudformation

<!-- Row 1: Status - Most Important -->
[![Release](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals/actions/workflows/release.yaml/badge.svg)](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)&nbsp;[![GitHub Repo](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)&nbsp;[![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals/issues)&nbsp;[![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals/commits)

<!-- Row 2: Code Quality -->
[![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)&nbsp;[![Commits](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals/commits)

<!-- Row 3: Tech Stack -->
[![CloudFormation](https://img.shields.io/badge/CloudFormation-IaC-orange?logo=amazon&logoColor=white)](https://aws.amazon.com/cloudformation/)&nbsp;[![Built with Claude Code](https://img.shields.io/badge/Built_with-Claude_Code-D97757?logo=anthropic&logoColor=white)](https://claude.ai/)

<!-- Row 4: Repository Info -->
[![Files](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)&nbsp;[![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)&nbsp;[![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals)](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals/releases)

<!-- Row 5: Custom Metrics -->
[![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/f55f73ac88992d4bd5c9835ee5fd70b6/raw/aws-vpc-cloudformation-fundamentals.json)](https://gist.github.com/subhamay-bhattacharyya/f55f73ac88992d4bd5c9835ee5fd70b6)

This repository contains a reusable nested CloudFormation template for deploying AWS VPC infrastructure with public subnets, internet gateway, and DNS configuration.

## Overview

This is a **nested stack template** designed to be invoked from a parent/root CloudFormation stack. The template automates VPC creation with configurable CIDR blocks, public subnets, internet gateway, and routing configuration suitable for multi-environment deployments (dev, staging, prod).

## Template Files

### CloudFormation Templates

- **`cloudformation/vpc-fundamentals.yaml`** — Parent template that orchestrates VPC networking infrastructure via nested stacks
- **VPC Nested Template** — Referenced from S3 (configurable via parameters)

### Parameter Files

- **`cloudformation/parameters.json`** — Default parameter values for development environment

## Template Features

- ✅ VPC creation with configurable CIDR blocks
- ✅ Public subnet(s) with automatic subnet CIDR allocation
- ✅ Internet Gateway attachment and route table configuration
- ✅ DNS hostnames and DNS support (optional)
- ✅ Public IP auto-assignment on instance launch (configurable)
- ✅ Network ACL support (optional)
- ✅ Multi-environment support with tags
- ✅ Export values for cross-stack references
- ✅ Support for high-availability multi-AZ deployments

## Parameters

| Parameter | Type | Default | Description |
| ----------- | ------ | --------- | ------------- |
| `VPCTemplateS3Bucket` | String | `subhamay-cfn-nested-templates-270453428528-devl-us-east-1` | S3 bucket containing the VPC nested template |
| `TemplatePrefix` | String | `cfn-nested-aws-ha-multi-az-vpc-subnets` | S3 prefix for the VPC nested template |
| `ApplicationPrefix` | String | `web` | Application prefix for resource naming |
| `EnvironmentName` | String | `devl` | Environment name (devl, stag, prod) |
| `VPCCidrBlock` | String | `10.2.0.0/16` | CIDR block for the VPC |
| `EnableInternetGateway` | String | `true` | Enable Internet Gateway attachment |
| `EnableDnsHostnames` | String | `true` | Enable DNS hostnames in VPC |
| `PublicSubnetCount` | String | `1` | Number of public subnets (0-4) |
| `PublicSubnetCidrBlocks` | String | `10.2.1.0/24` | CIDR blocks for public subnets (comma-separated) |
| `PublicSubnetAZ1` | String | `us-east-1a` | Availability Zone for first public subnet |
| `MapPublicIpOnLaunch` | String | `true` | Auto-assign public IPv4 to instances |
| `EnableNACLs` | String | `true` | Enable Network ACLs for subnets |

## Outputs

- `VpcId` — VPC ID (exported for cross-stack reference)
- `VpcCidrBlock` — VPC CIDR block
- `InternetGatewayId` — Internet Gateway ID (exported for cross-stack reference)
- `PublicSubnetIds` — Public Subnet IDs (exported for cross-stack reference)
- `PublicRouteTableId` — Public Route Table ID (exported for cross-stack reference)
- `EnvironmentName` — Environment Name (exported for cross-stack reference)

## Usage

### Deploy Using AWS CLI

```bash
# Deploy with default parameters (development environment)
aws cloudformation create-stack \
  --stack-name vpc-fundamentals-dev \
  --template-body file://cloudformation/vpc-fundamentals.yaml \
  --parameters file://cloudformation/parameters.json

# Wait for stack creation to complete
aws cloudformation wait stack-create-complete \
  --stack-name vpc-fundamentals-dev

# Retrieve stack outputs
aws cloudformation describe-stacks \
  --stack-name vpc-fundamentals-dev \
  --query 'Stacks[0].Outputs'
```

### Deploy Custom Configuration

```bash
# Deploy with custom VPC CIDR and multiple public subnets
aws cloudformation create-stack \
  --stack-name vpc-fundamentals-prod \
  --template-body file://cloudformation/vpc-fundamentals.yaml \
  --parameters \
    ParameterKey=EnvironmentName,ParameterValue=prod \
    ParameterKey=VPCCidrBlock,ParameterValue=10.0.0.0/16 \
    ParameterKey=PublicSubnetCount,ParameterValue=2 \
    ParameterKey=PublicSubnetCidrBlocks,ParameterValue="10.0.1.0/24,10.0.2.0/24" \
    ParameterKey=PublicSubnetAZ1,ParameterValue=us-east-1a \
    ParameterKey=MapPublicIpOnLaunch,ParameterValue=true
```

### Reference Outputs in Parent Stacks

```yaml
# Parent stack referencing VPC stack outputs
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      SubnetId: !ImportValue 'vpc-fundamentals-dev-public-subnet-ids'
      # Other instance properties...

Outputs:
  VpcId:
    Value: !ImportValue 'vpc-fundamentals-dev-vpc-id'
  VpcCidr:
    Value: !ImportValue 'vpc-fundamentals-dev-vpc-cidr'
```

## Multi-Environment Deployment

Deploy to multiple environments using separate parameter files:

```bash
# Development
aws cloudformation create-stack \
  --stack-name vpc-fundamentals-dev \
  --template-body file://cloudformation/vpc-fundamentals.yaml \
  --parameters file://cloudformation/parameters.json

# Staging
aws cloudformation create-stack \
  --stack-name vpc-fundamentals-stag \
  --template-body file://cloudformation/vpc-fundamentals.yaml \
  --parameters ParameterKey=EnvironmentName,ParameterValue=stag

# Production
aws cloudformation create-stack \
  --stack-name vpc-fundamentals-prod \
  --template-body file://cloudformation/vpc-fundamentals.yaml \
  --parameters ParameterKey=EnvironmentName,ParameterValue=prod
```

## Best Practices Implemented

- ✅ Nested stack pattern for reusability and modularity
- ✅ CloudFormation exports for cross-stack references
- ✅ Comprehensive parameter groups and labels for template UI
- ✅ Environment-specific tagging (Environment, ManagedBy, ParentStack)
- ✅ Configurable CIDR planning with validation
- ✅ DNS support for service discovery
- ✅ Optional Network ACLs for fine-grained network security
- ✅ Support for multi-AZ deployments with availability zone configuration

## License

MIT
