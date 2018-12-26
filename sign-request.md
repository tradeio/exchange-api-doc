Important Note: Do not reveal your 'SecretKey' to anyone. It is as important as your password.

## Components of a Query Request

TradeIO requires that each HTTPS request formatted for Signature should contain the following:

* Query parametr "<b>ts</b>": current timestamp.
* Header "<b>Sign</b>": The calculated value that ensures the signature is valid and is not tampered. Should be in UPPERCASE
* Header "<b>Key</b>": The 'PublicKey' distributed by TradeIO when you applied for APIKEY.

For examples please see Bash/Curl client https://gitlab.com/trade-io/official-api-docs/blob/master/api.sh and
C# client https://gitlab.com/trade-io/csharpclient


## How to Generate a Signature

Web service requests are sent across the Internet and are vulnerable to tampering. For security reasons,  TradeIO requires a signature as part of every request.



### Calculating sign.

```
GET
```
Example, GetCloseOrder have parametrs: start, end, limit, ts

Convert request parameters to this type of string:<br>
<b>?start=1544427829699&end=1544600629699&limit=100&ts=1544601074424</b>

Sign the resulting string with the algorithm SHA512
where key = you private key
Added resulting sign to Header "Sign"

```
POST
```
Example, PlaceOrder have parametrs: Symbol, Side, Type, Quantity, Price, ts

Convert request parameters to JSON format:<br>
<b>{"Symbol":"btc_usdt","Side":"buy","Type":"limit","Quantity":0.01,"Price":0.01,"ts":"1544601801600"}</b>

Sign the resulting string with the algorithm SHA512
where key = you private key
Added resulting sign to Header "Sign"


*  Secret key(The 'SecretKey' distributed by TradeIO when you applied for APIKEY.):

```
b0xxxxxx-c6xxxxxx-94xxxxxx-dxxxx
```

