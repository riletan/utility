#!/bin/bash
# riletan
# simple script to connect to ec2 instance via session manager
# Required: aws-cli aws-session-manager-plugin jq xargs
#################Configuration Section#############################
if [ "$2" == "refresh" ] || [ "$2" == "r" ] ; then
    FILTER=$4
    OPTION=$3
    CURRENT_PROFILE=$1
    [[ -z $CURRENT_PROFILE ]] && echo "Missing profile" && exit 1
else
    CURRENT_PROFILE=$1
    OPTION=$2
    FILTER=$3
    [[ -z $CURRENT_PROFILE ]] && echo "Missing profile" && exit 1
fi
SHOME=script_home_here
TMP=$SHOME/tmp/.$CURRENT_PROFILE.instances
SCACHE=$SHOME/tmp/.$CURRENT_PROFILE.cache
echo $SCACHE
PROMPT="On account: $CURRENT_PROFILE Please select a running instance to connect."
################### Helpful Function ############################
function show_loading() {
    local message="$1"
    local pid=$2
    local spin='-\|/'
    local i=0
    echo -n "$message "
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r$message ${spin:$i:1}"
        sleep .1
    done
    printf "\r$message done\n"
}

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
    # echo "Fetching instances"
    rm -f $SCACHE
    echo "[" >> $SCACHE
    (aws ec2 --profile $CURRENT_PROFILE describe-instances --query "Reservations[].Instances[].{InstanceId: InstanceId, Tags: Tags, State: State, NetworkInterfaces: NetworkInterfaces}" --output json | jq -c '.[]' | while read object; do
        parseInstances "$object"
    done
    echo "{}" >> $SCACHE
    echo "]" >> $SCACHE) &
    
    show_loading "Fetching instances from AWS" $!
    wait
}

function parseInstances()
{
    local state=`echo $1 | jq '.State' | jq '.Name'| xargs echo`
    if [ $state == "running" ]; then
        local instanceID=`echo $1 | jq '.InstanceId'`
        local tags=`echo $1 | jq '.Tags'`
        local name=$(getName "$tags" | xargs)
        # Replace spaces with dashes in name
        name=${name// /-}
        # Collect all private IPs into a JSON array
        local privateIPs=`echo $1 | jq '.NetworkInterfaces | map(.PrivateIpAddress)'`
        echo "{$instanceID:{\"Name\":\"$name\",\"PrivateIPs\":$privateIPs,\"InstanceID\":$instanceID}}," >>  $SCACHE
        
    fi
}
####################  Main ############################
if [ "$2" == "refresh" ] || [ "$2" == "r" ] ; then
    fetchInstances
else
    [[ ! -f $SCACHE ]] && fetchInstances
fi


rm -f $TMP
# echo "Processing instances..."
(list_instances=`cat $SCACHE | jq -c '.[]'`
for instance in $list_instances; do
    InstanceID=`echo $instance | jq -c '.[]' | jq '.InstanceID' | xargs echo`
    Name=`echo $instance | jq -c '.[]' | jq '.Name' | xargs echo`
    # Get the first IP from the array
    PrivateID=`echo $instance | jq -c '.[]' | jq '.PrivateIPs[0]' | xargs echo`
    if [ ! $InstanceID == "" ]; then
        if [ ! $FILTER == "" ]; then
            if [[ $Name == *"$FILTER"* ]]; then
                echo "$Name|$InstanceID|$PrivateID" >> $TMP
            fi
        else
            echo "$Name|$InstanceID|$PrivateID" >> $TMP
        fi
    fi
done) &

show_loading "Processing instance data" $!
wait

[[ ! -f $TMP ]] && echo "There're no instances matched on $CURRENT_PROFILE" && exit 1

echo 'Please select from the instances list:'
nl $TMP
count="$(cat $TMP | wc -l | xargs)"
n=""
while true; do
    read -p 'Select option: ' n
    # If $n is an integer between one and $count...
    if [[ "$n" -eq "$n" ]] && [[ "$n" -gt 0 ]] && [[ "$n" -le "$count" ]]; then
        break
    fi
done
value="$(sed -n "${n}p" $TMP)"
IFS='|' read -ra ADDR <<< "$value" 

case $OPTION in
  connect)
    echo "Connecting to instance $n: '$value'"
    aws --profile $CURRENT_PROFILE ssm start-session --target "${ADDR[1]}"
    ;;
  stop)
    echo "Stopping instance $n: '$value'"
    aws --profile $CURRENT_PROFILE ec2 stop-instances --instance-ids "${ADDR[1]}"
    ;;
  start)
    echo "Start instance $n: '$value'"
    aws --profile $CURRENT_PROFILE ec2 start-instances --instance-ids "${ADDR[1]}"
    ;;
  *)
    echo "Logging to $profile_name"
    echo "Connecting to instance $n: '$value'"
    aws --profile $CURRENT_PROFILE ssm start-session --target "${ADDR[1]}"
    ;;
esac