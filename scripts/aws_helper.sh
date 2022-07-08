#!/bin/bash
AWS_CONFIG=~/.aws/config
TMP=~/.aws/.tmp

ini_get () {
    awk -v section="profile $2" -v variable="$3" '
        $0 == "[" section "]" { in_section = 1; next }
        in_section && $1 == variable {
            $1=""
            $2=""
            sub(/^[[:space:]]+/, "")
            print
            exit 
        }
        in_section && $1 == "" {
            print "not found" > "/dev/stderr"
            exit 1
        }
    ' "$1"
}


# main scripts

[[ $1 != 'login' ]] && [[ $1 != 'cdk' ]] && [[ $1 != 'cdk' ]] && echo "Usage $(basename "$0") login|cdk|sam" && exit 1

all_profiles=$( cat ~/.aws/config | grep profile | awk '{print $2}' )
# echo $all_profiles

rm -f $TMP
for pro in $all_profiles; do 
    account_id=$( ini_get $AWS_CONFIG ${pro%?} sso_account_id )
    region=$( ini_get $AWS_CONFIG ${pro%?} region )
    echo " ${pro%?}|$account_id|$region|" >> $TMP
done

echo 'Please select profile:'
nl $TMP
count="$(cat $TMP | wc -l | xargs)"
n=""

while true; do
    read -p 'Select option: ' n
    # If $n is an integer between one and $count...
    echo $count
    if [[ "$n" -eq "$n" && "$n" -gt 0 && "$n" -le "$count" ]]; then
        break
    fi
done
value="$(sed -n "${n}p" $TMP)"

# 0 profile_name 1 account_id 2 region
IFS='|' read -ra ADDR <<< "$value" 

# aws --profile $CURRENT_PROFILE ssm start-session --target "${ADDR[1]}"

profile_name=`echo ${ADDR[0]} | xargs`
accountid=${ADDR[1]}
accregion=${ADDR[2]}

case $1 in
  login)
    echo "Logging to $profile_name"
    aws sso login --profile=$profile_name
    ;;
  cdk)
    pwd
    echo "CDK $2 to account $accountid region $accregion with profile=$profile_name"
    $@ --profile=$profile_name
    ;;
  sam)
    echo "Sam $2 to  account $accountid region $accregion with profile=$profile_name"
    $@ --profile=$profile_name
    ;;
  *)
    echo "Usage $(basename "$0") login|cdk|sam"
    ;;
esac