#!/bin/bash
wait=0
> failures
> other

while IFS='' read -r line || [[ -n "$line" ]]; do
        fqdn=$(echo $line | awk '{printf$1}')
        homeServer=$(echo $line | awk '{printf$2}')
        nodeId=$(echo $line | awk '{printf$3}')
        tAddr=$(echo $line | awk '{printf$4}')
        challenges=$(curl -s "https://securenodes$homeServer.zensystem.io/api/grid/$nodeId/crs")
        challengeRes=$(echo ${challenges} | jq -r '.rows[0].result')
        seconds=$(echo ${challenges} | jq -r '.rows[0].seconds')
        if [[ "$challengeRes" == 'wait' ]]
        then
                let wait++
        elif [[ "$challengeRes" == 'fail' ]]
        then
                echo "curl -s \"https://securenodes$homeServer.zensystem.io/$tAddr/$nodeId/send\"" >> failures
        elif [[ "$challengeRes" == 'confirm' ]] && [ $seconds -gt 300 ]
        then
                echo "curl -s \"https://securenodes$homeServer.zensystem.io/$tAddr/$nodeId/send\"" >> failures
                let wait++
        else
                echo "$fqdn : $challengeRes" >> other
        fi

done < /home/peastew/nodeDetails.txt

executed=$wait

while fails='' read -r line || [[ -n "$line" ]]; do
        if [ $executed -ge 3 ]
        then
                exit 1
        fi
        eval $line > /dev/null
        let executed++
done < failures
