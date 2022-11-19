# utility scripts on devops - sysops stuff

## Setup aws cli and  extra plugins

Please follow AWS Docs to install software

CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

→ Required

SSM: → https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

→ Optional, install it if you want to use session maganer (ssm connect bellow)

CDK → [https://aws.amazon.com/getting-started/guides/setup-cdk/](https://aws.amazon.com/getting-started/guides/setup-cdk/)

→ Optional, install it if you want to deploy for application with CDK

SAM → https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html

→ Optional, install it if you want to deploy severless applicaion via SAM

## Setup cli profiles
Add profile configuration like this in ~/.aws/config
You can get these information right after login sso account
```
[profile my-dev-profile]
sso_start_url = https://my-sso-portal.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789011
sso_role_name = readOnly
region = us-west-2
output = json
```
## Install
Install on Linux/WindowWSL
```
    cd somewhere safe
    git clone https://github.com/riletan/utility.git
    sh utility/install.linux
```
Install on MacOS
```
    cd somewhere safe
    git clone https://github.com/riletan/utility.git
    sh utility/install.macos
```

## Use Cases
* Login to AWS Profile 
```
    aws login
```
* Choose a profile to run any aws cli command you want
```
    amz aws s3 ls 
    amz cdk deploy 
```
* Connect ec2 intances using Session Manager (with aws cli helper )
```
    amz sc refresh|r filter_pattern
```

* Connect ec2 intances using Session Manager (Maunally input profile name)
```
    sc profile_name refresh|r filter_pattern
```
### Explain SSM connect 
```
    sc profile_name refresh|r filter_pattern
```
The first argument is profile_name. (Required)

The second argument is `r` or `refresh`. You need to refresh to see the change on instances (add/delete/change). (Optional)

The third argument is the filter pattern. If you want to see the instances that contain the `filter_pattern` (Optional)





    
