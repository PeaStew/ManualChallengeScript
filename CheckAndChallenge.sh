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
                continue
        elif [[ "$challengeRes" == 'confirm' ]] || [[ "$challengeRes" == 'overlap' ]]
        then
                continue
        elif [[ "$challengeRes" == 'fail' ]]
        then
                echo "curl -s \"https://securenodes$homeServer.zensystem.io/$tAddr/$nodeId/send\"" >> failures
                continue
        fi

        exceptions=$(curl -s "https://securenodes$homeServer.zensystem.io/api/grid/$nodeId/ex")
        exceptionType=$(echo ${exceptions} | jq -r '.rows[0].etype')
        exceptionResult=$(echo ${exceptions} | jq -r '.rows[0].end')
        if [[ "$exceptionType" == 'chalmax' ]] && [[ "$exceptionResult" == 'null' ]]
        then
                echo "curl -s \"https://securenodes$homeServer.zensystem.io/$tAddr/$nodeId/send\"" >> failures
        fi

done < /root/nodeDetails.txt

executed=$wait

while fails='' read -r line || [[ -n "$line" ]]; do
        if [ $executed -ge 3 ]
        then
                exit 1
        fi
        eval $line > /dev/null
        let executed++
done < failures
