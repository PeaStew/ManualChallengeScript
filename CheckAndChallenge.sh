#!/bin/bash
homeServer=$(cat ~/zencash/secnodetracker/config/home | cut -b 3-);
nodeId=$(cat ~/zencash/secnodetracker/config/nodeid);
tAddress=$(zen-cli listaddresses | grep -v ',\|\[\|]' | tr -d '\"\ ');
challenges=$(curl -s "https://securenodes$homeServer.zensystem.io/api/grid/$nodeId/crs")
challengeResult=$(python -c "import sys, json; print json.load(sys.stdin)['rows'][0]['result']" $challenges)
if [ $result == 'fail' ];
then curl -s "https://securenodes$homeServer.zensystem.io/$tAddress/$nodeId/send"; fi
