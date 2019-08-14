#!/bin/bash

get_price() {
    currency=$1
    python_code="import json, sys; print(json.load(sys.stdin)['bpi']['$currency']['rate'])"
    echo $(curl -s http://api.coindesk.com/v2/bpi/currentprice.json |\
        python -c "$python_code" |\
        sed -e "s/,//g" -e "s/\..*//g")
}

GBP_PRICE=$(get_price GBP)

echo "BTC £$GBP_PRICE"
