Important Note: Do not reveal your 'SecretKey' to anyone. It's as important as your password.

## Components of a Query Request

Trade.io requires that each HTTPS request formatted for Signature should contain the following:

* Query parameter "<b>ts</b>": current timestamp.
* Header "<b>Sign</b>": The calculated value that ensures the signature is valid and has not been tampered with. Should be in UPPERCASE.
* Header "<b>Key</b>": The 'PublicKey' distributed by Trade.io when you applied for APIKEY.

For examples, please see Bash/Curl client https://github.com/tradeio/exchange-api-doc/blob/master/api.sh and
C# client https://github.com/tradeio/api-csharpclient


## How to Generate a Signature

Web service requests that are sent across the Internet are vulnerable to tampering. For security reasons,  Trade.io requires a signature with every request.



### Calculating Signature

```
GET
```
Example:  GetCloseOrder has parameters: start, end, limit, ts

Convert request parameters to this type of string:<br>
<b>?start=1544427829699&end=1544600629699&limit=100&ts=1544601074424</b>

Sign the resulting string with the algorithm SHA512
where key = your private key and resulting signature to Header key "Sign"

```
POST
```
Example:  PlaceOrder has parameters: Symbol, Side, Type, Quantity, Price, ts

Convert request parameters to JSON format:<br>
<b>{"Symbol":"btc_usdt","Side":"buy","Type":"limit","Quantity":0.01,"Price":0.01,"ts":"1544601801600"}</b>

Sign the resulting string with the algorithm SHA512
where key = your private key and add resulting signature to Header key "Sign"


*  Secret key(The 'SecretKey' distributed by Trade.io when you applied for APIKEY):

```
b0xxxxxx-c6xxxxxx-94xxxxxx-dxxxx
```

