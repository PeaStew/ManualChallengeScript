#!/bin/bash
wait=0
fail=0
> failures.txt
while IFS='' read -r line || [[ -n "$line" ]]; do
        fqdn=$(echo $line | awk '{printf$1}')
        homeServer=$(echo $line | awk '{printf$2}')
        nodeId=$(echo $line | awk '{printf$3}')
        tAddr=$(echo $line | awk '{printf$4}')
        challenges=$(curl -s "https://securenodes$homeServer.zensystem.io/api/grid/$nodeId/crs")
        challengeRes=$(echo ${challenges} | jq -r '.rows[0].result')
        if [[ "$challengeRes" == 'wait' ]]
        then
                echo "$fqdn : $challengeRes"
                let wait++
        fi
        if [[ "$challengeRes" == 'fail' ]]
        then
                echo "$fqdn : $challengeRes"
                if [ $fail -lt 3 ]
                then
                        echo "curl -s \"https://securenodes$homeServer.zensystem.io/$tAddr/$nodeId/send\"" >> failures.txt
                fi
                let fail++
        fi

done < nodeDetails.txt

echo $wait
echo $fail
executed=$wait

while IFS='' read -r line || [[ -n "$line" ]]; do
        if [ $executed -ge 4 ]
        then
                exit 1
        fi
        eval $line
        let executed++
done < failures.txt
