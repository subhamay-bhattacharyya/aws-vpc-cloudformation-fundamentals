---
name: vpc-fundamentals
description: Guide for creating CloudFormation nested stack templates for VPC and subnet deployment. Use when building, modifying, or troubleshooting VPC infrastructure templates, designing subnet architecture, or implementing multi-environment VPC configurations.
---

# VPC Fundamentals Skill

Guide for creating CloudFormation nested stack templates to deploy VPC and public subnet infrastructure.

## Overview

This skill covers the nested stack pattern for VPC infrastructure, enabling reusable templates that can be referenced by parent CloudFormation stacks via `TemplateURL`.

## Nested Stack Pattern for VPC

**Key concepts:**

- **Parent stack** references nested templates via `AWS::CloudFormation::Stack` resource with `TemplateURL` pointing to S3
- **Nested templates** export outputs via `Outputs` section with `Export` key
- **Cross-stack references** via `!GetAtt NestedStack.Outputs.OutputKey`

**Example parent stack reference:**

```yaml
VPCStack:
  Type: AWS::CloudFormation::Stack
  Properties:
    TemplateURL: https://s3.amazonaws.com/bucket/vpc-template.yaml
    Parameters:
      VpcCidr: 10.0.0.0/16
      Environment: dev
    Tags:
      - Key: Environment
        Value: !Ref Environment

PublicSubnetId: !GetAtt VPCStack.Outputs.PublicSubnetId
```

## VPC Template Structure

### Parameters

Standard VPC template parameters:

```yaml
Parameters:
  VpcCidr:
    Type: String
    Description: CIDR block for VPC
    Default: 10.0.0.0/16
    AllowedPattern: ^(\d{1,3}\.){3}\d{1,3}/\d{1,2}$

  PublicSubnetCidr:
    Type: String
    Description: CIDR block for public subnet
    Default: 10.0.1.0/24

  Environment:
    Type: String
    Description: Environment name (dev, staging, prod)
    AllowedValues: [dev, staging, prod]

  AvailabilityZone:
    Type: AWS::EC2::AvailabilityZone::Name
    Description: AZ for subnet deployment

  EnableFlowLogs:
    Type: String
    Default: "false"
    AllowedValues: ["true", "false"]
    Description: Enable VPC Flow Logs
```

### Core Resources

**VPC:**
```yaml
VPC:
  Type: AWS::EC2::VPC
  Properties:
    CidrBlock: !Ref VpcCidr
    EnableDnsHostnames: true
    EnableDnsSupport: true
    Tags:
      - Key: Name
        Value: !Sub '${Environment}-vpc'
```

**Internet Gateway:**
```yaml
InternetGateway:
  Type: AWS::EC2::InternetGateway
  Properties:
    Tags:
      - Key: Name
        Value: !Sub '${Environment}-igw'

AttachGateway:
  Type: AWS::EC2::VPCGatewayAttachment
  Properties:
    VpcId: !Ref VPC
    InternetGatewayId: !Ref InternetGateway
```

**Public Subnet:**
```yaml
PublicSubnet:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref VPC
    CidrBlock: !Ref PublicSubnetCidr
    AvailabilityZone: !Ref AvailabilityZone
    MapPublicIpOnLaunch: true
    Tags:
      - Key: Name
        Value: !Sub '${Environment}-public-subnet'
```

**Route Table & Routes:**
```yaml
PublicRouteTable:
  Type: AWS::EC2::RouteTable
  Properties:
    VpcId: !Ref VPC
    Tags:
      - Key: Name
        Value: !Sub '${Environment}-public-rt'

PublicRoute:
  Type: AWS::EC2::Route
  DependsOn: AttachGateway
  Properties:
    RouteTableId: !Ref PublicRouteTable
    DestinationCidrBlock: 0.0.0.0/0
    GatewayId: !Ref InternetGateway

SubnetRouteTableAssociation:
  Type: AWS::EC2::SubnetRouteTableAssociation
  Properties:
    SubnetId: !Ref PublicSubnet
    RouteTableId: !Ref PublicRouteTable
```

### Outputs

Export outputs for use by parent stacks:

```yaml
Outputs:
  VpcId:
    Description: VPC ID
    Value: !Ref VPC
    Export:
      Name: !Sub '${Environment}-vpc-id'

  VpcCidr:
    Description: VPC CIDR block
    Value: !GetAtt VPC.CidrBlock
    Export:
      Name: !Sub '${Environment}-vpc-cidr'

  PublicSubnetId:
    Description: Public subnet ID
    Value: !Ref PublicSubnet
    Export:
      Name: !Sub '${Environment}-public-subnet-id'

  InternetGatewayId:
    Description: Internet Gateway ID
    Value: !Ref InternetGateway
    Export:
      Name: !Sub '${Environment}-igw-id'
```

## Parameters Configuration

Create environment-specific parameter files in `cloudformation/` directory:

**parameters.json (example for dev):**
```json
[
  {
    "ParameterKey": "VpcCidr",
    "ParameterValue": "10.0.0.0/16"
  },
  {
    "ParameterKey": "PublicSubnetCidr",
    "ParameterValue": "10.0.1.0/24"
  },
  {
    "ParameterKey": "Environment",
    "ParameterValue": "dev"
  },
  {
    "ParameterKey": "AvailabilityZone",
    "ParameterValue": "us-east-1a"
  }
]
```

## Best Practices

### 1. CIDR Planning

- Use non-overlapping CIDR blocks across environments
- Reserve space for future subnets (e.g., private subnets, database subnets)
- Example: VPC `10.0.0.0/16` → Public `10.0.1.0/24`, Private `10.0.2.0/24`

### 2. Tagging Strategy

Tag all resources for cost tracking and automation:

```yaml
Tags:
  - Key: Environment
    Value: !Ref Environment
  - Key: ManagedBy
    Value: CloudFormation
  - Key: TemplateName
    Value: vpc-fundamentals
```

### 3. Security Defaults

- Enable DNS hostnames and DNS support
- Use `MapPublicIpOnLaunch: true` only for public subnets
- Consider Network ACLs for subnet-level filtering
- Document security group rules in parent stacks

### 4. Flow Logs (Optional)

Enable VPC Flow Logs for network monitoring:

```yaml
VPCFlowLogRole:
  Type: AWS::IAM::Role
  Properties:
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: vpc-flow-logs.amazonaws.com
          Action: sts:AssumeRole

VPCFlowLog:
  Type: AWS::EC2::FlowLog
  Properties:
    ResourceType: VPC
    ResourceId: !Ref VPC
    TrafficType: ALL
    LogDestinationType: cloud-watch-logs
    LogGroupName: !Sub '/aws/vpc/flowlogs/${Environment}'
    DeliverLogsPermissionIAM: !GetAtt VPCFlowLogRole.Arn
```

## Template Validation

### Validate locally

```bash
aws cloudformation validate-template --template-body file://cloudformation/vpc-fundamentals.yaml
```

### Deploy to dev environment

```bash
aws cloudformation deploy \
  --template-file cloudformation/vpc-fundamentals.yaml \
  --stack-name vpc-fundamentals-dev \
  --parameter-overrides file://cloudformation/parameters.json \
  --region us-east-1 \
  --capabilities CAPABILITY_IAM
```

### Verify stack outputs

```bash
aws cloudformation describe-stacks \
  --stack-name vpc-fundamentals-dev \
  --region us-east-1 \
  --query 'Stacks[0].Outputs'
```

## Multi-Environment Setup

Structure parameters for dev/staging/prod:

```
cloudformation/
├── vpc-fundamentals.yaml      # Template (shared across environments)
├── parameters.json            # Default/dev parameters
├── parameters-staging.json    # Staging overrides
└── parameters-prod.json       # Production overrides
```

Deploy to different environments:

```bash
# Dev
aws cloudformation deploy \
  --stack-name vpc-dev \
  --parameter-overrides file://cloudformation/parameters.json

# Staging
aws cloudformation deploy \
  --stack-name vpc-staging \
  --parameter-overrides file://cloudformation/parameters-staging.json

# Production
aws cloudformation deploy \
  --stack-name vpc-prod \
  --parameter-overrides file://cloudformation/parameters-prod.json
```

## Common Patterns

### Adding a Private Subnet

Extend template with private subnet (no internet access):

```yaml
PrivateSubnet:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref VPC
    CidrBlock: 10.0.2.0/24
    AvailabilityZone: !Ref AvailabilityZone
    Tags:
      - Key: Name
        Value: !Sub '${Environment}-private-subnet'

PrivateRouteTable:
  Type: AWS::EC2::RouteTable
  Properties:
    VpcId: !Ref VPC

PrivateSubnetRouteTableAssociation:
  Type: AWS::EC2::SubnetRouteTableAssociation
  Properties:
    SubnetId: !Ref PrivateSubnet
    RouteTableId: !Ref PrivateRouteTable
```

### Adding NAT Gateway (for private subnet internet access)

```yaml
NATGatewayEIP:
  Type: AWS::EC2::EIP
  DependsOn: AttachGateway
  Properties:
    Domain: vpc
    Tags:
      - Key: Name
        Value: !Sub '${Environment}-nat-eip'

NATGateway:
  Type: AWS::EC2::NatGateway
  Properties:
    AllocationId: !GetAtt NATGatewayEIP.AllocationId
    SubnetId: !Ref PublicSubnet
    Tags:
      - Key: Name
        Value: !Sub '${Environment}-nat'

PrivateRoute:
  Type: AWS::EC2::Route
  Properties:
    RouteTableId: !Ref PrivateRouteTable
    DestinationCidrBlock: 0.0.0.0/0
    NatGatewayId: !Ref NATGateway
```

## CI/CD Integration

The CI workflow (`.github/workflows/ci.yaml`) automatically:

1. Validates templates on PR
2. Deploys to CI environment for testing
3. Cleans up stacks after validation
4. Runs on `feature/**` and `bug/**` branches

Trigger manual validation:

```bash
npx commitizen commit  # Use conventional commits
git push origin your-branch
# GitHub Actions runs CI automatically
```

## Troubleshooting

### Stack creation fails with CIDR conflict

- Verify CIDR blocks don't overlap with existing VPCs
- Check AWS account VPC quotas

### Subnet creation fails

- Verify CIDR block is subset of VPC CIDR
- Check AZ exists in region
- Ensure no CIDR overlap within VPC

### Export conflicts

- Export names must be unique within region
- Use environment prefix: `${Environment}-resource-name`
- Check for existing stacks with same export names

## See Also

- [CONTRIBUTING.md](../../CONTRIBUTING.md) — Commit conventions and branch workflow
- [CI/CD Workflow](./.github/workflows/ci.yaml) — Automated validation and deployment
- AWS CloudFormation Documentation — VPC and subnet resource references
