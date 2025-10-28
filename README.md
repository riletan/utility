# AWS DevOps Utility Scripts

A collection of utility scripts designed to streamline AWS DevOps and SysOps operations, including simplified AWS CLI interactions, SSM connections, and EC2 instance management.

## Prerequisites

### Required Dependencies

Install the following software components by following the official AWS documentation:

#### AWS CLI (Required)
- **Documentation**: [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Purpose**: Core AWS command-line interface for all AWS operations

#### AWS Systems Manager Session Manager Plugin (Optional)
- **Documentation**: [Session Manager Plugin Installation](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
- **Purpose**: Enables secure shell access to EC2 instances without SSH keys or bastion hosts
- **Required for**: SSM connect functionality described below

#### AWS CDK (Optional)
- **Documentation**: [AWS CDK Setup Guide](https://aws.amazon.com/getting-started/guides/setup-cdk/)
- **Purpose**: Infrastructure as Code deployments using AWS Cloud Development Kit

#### AWS SAM (Optional)
- **Documentation**: [AWS SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html)
- **Purpose**: Serverless application deployment and testing

## Configuration

### AWS CLI Profile Setup

Configure AWS CLI profiles for SSO authentication by adding the following configuration to `~/.aws/config`:

```ini
[profile my-dev-profile]
sso_start_url = https://my-sso-portal.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789011
sso_role_name = readOnly
region = us-west-2
output = json
```

> **Note**: Replace the values with your organization's SSO configuration details, which can be obtained from your AWS SSO portal after login.

## Installation

### Linux/Windows WSL

```bash
cd /path/to/installation/directory
git clone https://github.com/riletan/utility.git
chmod +x utility/install.linux
./utility/install.linux
```

### macOS

```bash
cd /path/to/installation/directory
git clone https://github.com/riletan/utility.git
chmod +x utility/install.macos
./utility/install.macos
```
## Update
Pull the latest change from main and run install script again.
## Usage

### AWS Profile Authentication

Log in to your configured AWS profile:

```bash
amz login
```

### AWS CLI Operations

Execute AWS CLI commands using your selected profile:

```bash
# List S3 buckets
amz aws s3 ls

# Deploy CDK stack
amz cdk deploy
```

### EC2 Instance Management via Session Manager

#### Connect to EC2 Instances

**Using automatic profile selection:**
```bash
amz sc [refresh|r] [filter_pattern]
```

**Using manual profile specification:**
```bash
sc <profile_name> [refresh|r] [filter_pattern]
```

### SSM Connect Command Reference

#### Syntax
```bash
sc <profile_name> [refresh|r] [filter_pattern]
```

#### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `profile_name` | Yes | AWS CLI profile name configured in `~/.aws/config` |
| `refresh` or `r` | No | Refresh the instance cache to reflect current state |
| `filter_pattern` | No | Filter instances by name containing this pattern |

#### Examples

```bash
# Connect to any instance in the dev-profile
sc dev-profile

# Refresh instance list and connect to instances containing "web"
sc dev-profile refresh web

# Filter instances by "database" pattern
sc dev-profile r database
```

## Features

- **Simplified AWS Authentication**: Streamlined SSO login process
- **Interactive Instance Selection**: Browse and select EC2 instances from a numbered list
- **Instance Filtering**: Filter instances by name patterns for faster access
- **Session Manager Integration**: Secure shell access without SSH keys or bastion hosts
- **Instance Caching**: Improves performance by caching instance metadata





    
