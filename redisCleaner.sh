#!/bin/bash
#get redis key => get ttl => search keyword in value => del
set +o verbose

PORT=6379
DATA=$(redis-cli -p $PORT --raw SCAN $1 COUNT 50000 MATCH "prefix:*")
re='^[0-9]+$'
text='M_NO'
scanNum=0
count=0
deletedCount=0
notdeletedCount=0

echo "Argument is $1"

for i in ${DATA}
do
    ((count=count+1))
    echo "count is $count"
    ttl=""
    val=""
    if [[ $i =~ $re ]] ; then
        scanNum="$i"
    else
        ttl=$(redis-cli -p $PORT TTL $i)
        if (( $ttl > 86400 )) ; then
            val=$(redis-cli -p $PORT GET $i)
            if ! [[ $val == *"value-keyword"* ]] ; then
                ((deletedCount=deletedCount+1))
                output=$(redis-cli -p $PORT DEL $i)
            else
                ((notdeletedCount=notdeletedCount+1))
            fi

        fi
    fi
done

echo "NEXT SCAN IS $scanNum"
echo "DELETED COUNT IS $deletedCount"
echo "NOT DELETED COUNT IS $notdeletedCount"
