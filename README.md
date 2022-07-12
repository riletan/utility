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

## Clone this repository 
```
    git clone https://github.com/riletan/utility.git
```

## aws_helper.sh: a helper script that help login and deploy CDK|SAM app with different profiles

Install on Linux/WindowWSL/MacOS
    cd utility/scripts
    chmod u+x aws_helper.sh
    sudo ln -s $PWD/aws_helper.sh /usr/local/bin/amz
    usage: amz login
           amz cdk deploy|...
           amz sam deploy|...

## ssm_connect.sh : a small utility to connect to ec2 instances that is using session manager 
### Install

Instll JQ
You need to have [JQ](https://stedolan.github.io/jq/) installed to run the script 


Install on Linux/ Window WSL (Debian)
```
     cd utility/scripts
     sudo apt-get install jq
     chmod u+x ssm_connect.sh
     sed -i "s|script_home_here|$PWD|g" ssm_connect.sh
     mkdir -p tmp
     sudo ln -s $PWD/ssm_connect.sh /usr/local/bin/sc
```

Install on MacOS
```
     cd utility/scripts
     brew install jq
     sed -i -e "s|script_home_here|$PWD|g" ssm_connect.sh
     mkdir -p tmp
     sudo ln -s $PWD/ssm_connect.sh /usr/local/bin/sc
```
I'v just tested the scripts on Window wsl and MacOS. If you face any issues, please let' me know.

### How to use
Use must login to sso before you can use the script. If you have installed the aws helper script above, just run the script and chosse the profile to login. If not, just run aws native command below, the login session will last 8hours.

```
    aws sso login --profile=profile_name
```

The first argument is profile_name. (Required)

The second argument is `r` or `refresh`. You need to refresh to see the change on instances (add/delete/change). (Optional)

The third argument is the filter pattern. If you want to see the instances that contain the `filter_pattern` (Optional)

```
    sc profile_name refresh|r filter_pattern
```




    
