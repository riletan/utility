# utility script on devops - sysops stuff

## Setup aws cli and 

Please follow AWS Docs to install cli and session maanger plugin

CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

SSM: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

## Setup cli profile
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

## ssm_connect.sh : A small utility to connect to ec2 instances that is using session manager 
### Install
     ```
     # Clone this repository 
     git clone https://github.com/riletan/utility.git
     cd utility/scripts
     (Linux)
     sed -i "s|script_home_here|$PWD|g" ssm_connect.sh
     (MacOS)
     sed -i -e "s|script_home_here|$PWD|g" ssm_connect.sh
     (both)
     mkdir -p tmp
     sudo ln -s $PWD/ssm_connect.sh /usr/local/bin/sc
     ```
### How to use
Use must login to sso before you can use the script. The login session will last 8hours.

    ```
      aws sso login --profile=profile_name 
    ```

The first argument is profile_name. (Required)

The second argument is `r` or refresh. You need to refresh to see the change on instances (add/delete/change). (Optional)

The third argument is the filter pattern. If you want to see the instances that contain the `filter_pattern` (Optional)

    ```
      sc profile_name refresh|r filter_pattern
    ```
    
