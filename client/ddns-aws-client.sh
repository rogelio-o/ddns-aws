#!/bin/bash

## Recommend /tmp/ddns_cache/ to clear cache on restart
cacheFileDir="/tmp/ddns_cache/" 
cacheFileExt=".ddns.tmp"

fail () {
    echo "$(basename $0): $1"
    exit 1
}

help () {
    cat << EOF
Set the IP for a specific hostname on route53
ddns-aws-client.sh [options]
Options:
    -h, --help
        Display this help and exit.
    --api-key API_KEY
        Pass the Amazon API Gateway API Key
    --url API_URL
        The URL where to send the requests.
EOF
}

# Parse arguments
while [[ $# -ge 1 ]]; do
    i="$1"
    case $i in
        -h|--help)
            help
            exit 0
            ;;
        --api-key)
            if [ -z "$2" ] ; then
                fail "\"$1\" argument needs a value."
            fi
			apiKey="$2"
            shift
            ;;
        --url)
            if [ -z "$2" ] ; then
                fail "\"$1\" argument needs a value."
            fi
            myAPIURL=$2
            shift
            ;;
        *)
            fail "Unrecognized option $1."
            ;;
    esac
    shift
done

# If the script is called with no arguments, show an instructional error message.
if [ -z "$myAPIURL" ]; then
    echo "$(basename $0): Required arguments missing."
    help
    exit 1
fi

cacheFile="$cacheFileDir$cacheFileExt"

if [ -f "$cacheFile" ]; then
    cached_myIp=$(cat $cacheFile)
    echo "$(basename $0): Found a cached IP $cached_myIp"
else
    cached_myIp=""
fi

myIp=$(curl -q --ipv4 -s -d '' -H "x-api-key: $apiKey" "$myAPIURL?last_ip=$cached_myIp" | jq -r '.return_message //empty')

[ -z "$myIp" ] && fail "Couldn't find your public IP"

echo "$myIp" > $cacheFile
echo "$(basename $0): Host updated to IP $myIp"