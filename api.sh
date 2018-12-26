#!/usr/bin/env bash

# script to play with authorized API endpoints
# usage ./api.sh <COMMAND>
#  where COMMAND is one of: order, account, openOrders, closedOrders
#  e.g.
#  ./api.sh account

# you should set your public and private keys here, generate them in terminal
#publicKey=00000000-0000-0000-0000-111111111111
#pvtKey=00000000-0000-0000-0000-222222222222


if [[ -z $publicKey ]]; then
    echo "Please set your public key in publicKey variable"
    exit 1
fi

if [[ -z $pvtKey ]]; then
    echo "Please set your private key in pvtKey variable"
    exit 1
fi


baseUrl=https://api.exchange.trade.io/api/v1

ts=$(date +%s)000
echo "Timestamp: $ts"


doSign() {
    local body=$1
    echo "Signing body $body"

# openssl produce output like: "(stdin)= c0ec90298......"
# awk is used to remove "(stdin)= " part from answer
    local sign0=$(echo -n "$body" | openssl dgst -sha512 -hmac "$pvtKey" | awk '{print $2}')
    sign=${sign0^^}  # sign in uppercase
    echo "Sign: $sign"
}

order() {
    local form='{"Symbol":"ltc_btc","Side":"buy","Type":"limit","Quantity":100000,"Price":0.0012,"ts":"'
    form+="$ts"
    form+='"}'
    echo "Form $form"
    
    doSign "$form"
    
    curl -sS -i -H "Sign: $sign" -H "Key: $publicKey"  -H "accept: application/json" -H "Content-Type: application/json" -X POST "$baseUrl/order" -d "$form"
}

cancelOrder() {
    local id=$1
    local body="?ts=$ts"
    doSign "$body"

    curl -sS -i -H "Sign: $sign" -H "Key: $publicKey" -H "accept: application/json" -X DELETE "$baseUrl/order/$id$body"
}

cancel() {
    cancelOrder $@
}


account() {
    local body="?ts=$ts"
    doSign "$body"

    curl -sS -i -H "Sign: $sign" -H "Key: $publicKey" -H "accept: application/json" -X GET "$baseUrl/account$body" 
}

openOrders() {
    local body="?ts=$ts"
    doSign "$body"

    curl -sS -i -H "Sign: $sign" -H "Key: $publicKey" -H "accept: application/json" -X GET "$baseUrl/openOrders/all/$body"
}

closedOrders() {
    local body="?ts=$ts"
    doSign "$body"

    curl -sS -i -H "Sign: $sign" -H "Key: $publicKey" -H "accept: application/json" -X GET "$baseUrl/closedOrders/all/$body"
}

cmd=$1
shift
echo "Command $cmd"
echo "Args $@"
$cmd $@ 
