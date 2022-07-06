# utility script on devops - sysops stuff

## Setup aws cli and 

Please follow AWS Docs to install cli and session maanger plugin

CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

SSM: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

## Setup cli profile
Add profile configuration like this in ~/.aws/config

[profile my-dev-profile]
sso_start_url = https://my-sso-portal.awsapps.com/start
sso_region = us-east-1
sso_account_id = 123456789011
sso_role_name = readOnly
region = us-west-2
output = json


## ssm_connect.sh : A small utility to connect to ec2 instances that is using session manager 
### Install
     ```
     # Clone this repository 
     git clone git@github.com:riletan/utility.git
     cd utility/scripts
     sed -i "s|script_home_here|$PWD|g" ssm_connect.sh
     mkdir -p tmp
     sudo ln -s $PWD/ssm_connect.sh /usr/local/bin/sc
     ```
### How to use
    ```
    sc profile_name refresh|r filter_pattern
    ```