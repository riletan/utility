#!/bin/bash
# riletan
# simple script to connect to ec2 instance via session manager
# Required: aws-cli aws-session-manager-plugin jq xargs
CURRENT_PROFILE='mf-dev'
#################Configuration Section#############################
SHOME=/mnt/c/Users/riletan/Workspace/Scripts
TMP=$SHOME/tmp/.$CURRENT_PROFILE.instances
SCACHE=$SHOME/tmp/.$CURRENT_PROFILE.cache
PROMPT="On account: $CURRENT_PROFILE Please select a running instance to connect."
################### Helpful Function ############################
function printName() 
{
    line='_______________________'
    # PROC_NAME=`echo $1 | awk '{print tolower($0)}'`
    [[ "$1" == "" ]] && PROC_NAME="Noname" || PROC_NAME=$1
    # printf "\"Name:%s%s" $PROC_NAME "${line:${#PROC_NAME}}" >> $SCACHE
    printf "\"Name:%s__" $PROC_NAME >> $SCACHE
    #  printf -v pad "\"Name:%s" "-"{1..60} >> $TMP
}
function getName() 
{
    if  ! [ "$@" == "null" ]; then
        echo $@ | jq -c '.[]' | while read Tag; do
            [[ $Tag == *"\"Name\""* ]] && echo $Tag | jq '.Value' | xargs echo  
        done
    else 
       echo "Unknown"
    fi 
}
function fetchInstances() 
{   
    echo "Fetching instances"
    rm -f $SCACHE
    echo "[" >> $SCACHE
    aws ec2 --profile $CURRENT_PROFILE describe-instances --query "Reservations[].Instances[].{InstanceId: InstanceId, Tags: Tags, State: State, NetworkInterfaces: NetworkInterfaces}" --output json | jq -c '.[]' | while read object; do
        # echo "$object" >> $SCACHE
        parseInstances "$object"
    done
    echo "{}" >> $SCACHE
    echo "]" >> $SCACHE
}

function parseInstances()
{
    local state=`echo $1 | jq '.State' | jq '.Name'| xargs echo`
    if [ $state == "running" ]; then
        local instanceID=`echo $1 | jq '.InstanceId'`
        local tags=`echo $1 | jq '.Tags'`
        local name=$(getName "$tags") 
        local privateIP=`echo $1 | jq '.NetworkInterfaces' | jq -c '.[]' | jq '.PrivateIpAddress' | xargs echo`
        echo "{$instanceID:{\"Name\":\"$name\",\"PrivateIP\":\"$privateIP\",\"InstanceID\":$instanceID}}," >>  $SCACHE
        
    fi
}
####################  Main ############################
if [ "$1" == "refresh" ] || [ "$1" == "r" ] ; then
    fetchInstances
else
    [[ ! -f $SCACHE ]] && fetchInstances
fi

rm -f $TMP
list_instances=`cat $SCACHE | jq -c '.[]'`
for instance in $list_instances; do 
    InstanceID=`echo $instance | jq -c '.[]' | jq '.InstanceID' | xargs echo`
    Name=`echo $instance | jq -c '.[]' | jq '.Name' | xargs echo`
    PrivateID=`echo $instance | jq -c '.[]' | jq '.PrivateIP' | xargs echo`
    if [ ! $InstanceID == "" ]; then
        echo "$Name|$InstanceID|$PrivateID" >> $TMP
    fi
done
[[ ! -f $TMP ]] && Echo "There're no instances on $CURRENT_PROFILE" && exit 1
echo 'Please select from the instances list:'
nl $TMP
count="$(wc -l $TMP | cut -f 1 -d' ')"
n=""
while true; do
    read -p 'Select option: ' n
    # If $n is an integer between one and $count...
    if [ "$n" -eq "$n" ] && [ "$n" -gt 0 ] && [ "$n" -le "$count" ]; then
        break
    fi
done
value="$(sed -n "${n}p" $TMP)"
echo "Connecting to instance $n: '$value'"
IFS='|' read -ra ADDR <<< "$value" 
aws --profile $CURRENT_PROFILE ssm start-session --target "${ADDR[1]}"