#!/bin/bash
wait=0
fail=0
> failures
> other

while IFS='' read -r line || [[ -n "$line" ]]; do
        fqdn=$(echo $line | awk '{printf$1}')
        homeServer=$(echo $line | awk '{printf$2}')
        nodeId=$(echo $line | awk '{printf$3}')
        tAddr=$(echo $line | awk '{printf$4}')
        challenges=$(curl -s "https://securenodes$homeServer.zensystem.io/api/grid/$nodeId/crs")
        challengeRes=$(echo ${challenges} | jq -r '.rows[0].result')
        if [[ "$challengeRes" == 'wait' ]]
        then
                let wait++
        elif [[ "$challengeRes" == 'fail' ]]
        then
                echo "curl -s \"https://securenodes$homeServer.zensystem.io/$tAddr/$nodeId/send\"" >> failures
                let fail++
        else
                echo "$fqdn : $challengeRes" >> other
        fi

done < /home/peastew/nodeDetails.txt

#echo $wait
#echo $fail
executed=$wait

while fails='' read -r line || [[ -n "$line" ]]; do
        if [ $executed -ge 3 ]
        then
                exit 1
        fi
        eval $line > /dev/null
        let executed++
done < failures
