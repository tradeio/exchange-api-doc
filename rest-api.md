# Public Rest API for Trade.io (2018-12-26)
# General API Information
* The base endpoint is: **https://api.exchange.trade.io**, 
* There is a Swagger on the base endpoint. You can open it in browser, see available endpoints, execute some API calls
 and so on.
* All endpoints return either a JSON object or array.
* Data is returned in **ascending** order. Oldest first, newest last.
* All time and timestamp related fields are in milliseconds.
* HTTP `4XX` return codes are used for for malformed requests;
  the issue is on the sender's side.
* HTTP `429` status code is used when breaking a request rate limit.
* HTTP `418` status code is used when an IP address has been auto-banned for keeping sending requests after receiving `429` codes.
* HTTP `5XX` status codes are used for internal errors - the issue is on Trade.io's side.
  It is important to **NOT** treat this as a failure operation; the execution status is
  **UNKNOWN** and could have been succeeded.
* Any endpoint can return an ERROR; the error payload is as follows:
```javascript
{
    "error":"Invalid value symbol: 'btc_us'"
}
```
* When endpoint's response is success, the code is 0 and no message present. 
* Specific error codes and messages defined in another document.
* For `GET` endpoints, parameters must be sent as a `query string`.
* For `POST`, `PUT`, and `DELETE` endpoints, the parameters may be sent as a
  `query string` or in the `request body` with content type
  `application/json`. Mixing of parameters between both the
  `query string` and `request body` is allowed.
* Parameters may be sent in any order.
* If a parameter sent in both `query string` and `request body`, the
  `query string` parameter will be used.

# Limits
* The `/api/v1/about` `rateLimits` array contains objects related to the exchange's `Weight` or `Order` rate limits.
* A HTTP/429 status code will be returned when either rate limit is violated.
* Each route has a `Weight` which determines the number of allowed requests per defined time frame for each endpoint.
* When a HTTP/429 is received, it is your obligation as an API user to control requests rate and not spam the API endpoint.
* **Repeatedly violating rate limits and/or failing to back off after receiving HTTP/429 responses will result in an automated IP ban (HTTP/418 status).**
* IP ban durations are scaled according to the frequency of spamming requests - from **2 minutes** to 3 **days**.

## Endpoint Throttling
The endpoint throttling is being performed according to the weight of the endpoint. Limit type can be either `Weight` or combination of `Weight` and `Order`:
* `Weight` throttling - for each endpoint the weights of requests are being accumulated. When the sum reaches the threshold, the server responds with HTTP/429 status code.
* `Weight` or `Order` throttling - for each endpoint the weights and number of orders are being accumulated. When either of sums reaches the threshold, the server responds with HTTP/429 status code.

Below is the table with endpoint weights

|**Endpoint**|**Limit Type**|**Weight**|**Remarks**|
|---|---|---|---|
|```GET /api/v1/info```|`Weight`|5|
|```GET /api/v1/pairs```|`Weight`|1|
|```GET /api/v1/depth```|`Weight`|1 + (`limit` / 20)|`limit` is a parameter of of endpoint's GET request| 
|```GET /api/v1/trades```|`Weight`|1 + (`limit` / 20)|`limit` is a parameter of of endpoint's GET request|
|```GET /api/v1/klines```|`Weight`|1 + (`limit` / 20)|`limit` is a parameter of of endpoint's GET request|
|```GET /api/v1/ticker```|`Weight`|1|
|```GET /api/v1/tickers```|`Weight`|20|
|```POST /api/v1/order```|`Weight` or `Order`|1|
|```DELETE /api/v1/order```|`Weight` or `Order`|1|
|```GET /api/v1/openOrders```|`Weight` or `Order`|1|
|```GET /api/v1/closedOrders```|`Weight` or `Order`|5|
|```GET /api/v1/account```|`Weight` or `Order`|1|
 
# Endpoint Security Type
* Each endpoint has a security type that determines how should be interacted with it.
* API-keys are passed into the REST API via the `X-MBX-APIKEY`
  header.
* API-keys and secret-keys are **case sensitive**.
* API-keys can be configured to only access certain types of secure endpoints.
 For example, one API-key could be used for TRADE only, while another API-key
 can access everything except for TRADE routes.
* By default, API-keys can access all secure routes.

Security Type | Description
------------ | ------------
NONE | Endpoint can be accessed freely.
MARKET_DATA | Endpoint can be accessed freely.
TRADE | Endpoint requires sending a valid API-Key and signature.
USER_DATA | Endpoint requires sending a valid API-Key and signature.


* `TRADE` and `USER_DATA` endpoints are `SIGNED` endpoints.


# SIGNED (TRADE and USER_DATA) Endpoint Security
* `SIGNED` endpoints require an additional parameter `signature` to be
  sent in the `query string` or `request body`.
* Endpoints use `HMAC SHA512` signatures. The `HMAC SHA512 signature` is a keyed `HMAC SHA512` operation.
  Use your `secretKey` as the key and `totalParams` as the value for the HMAC operation.
* The `signature` should be in uppercase.
* `totalParams` is a concatenation of `query string` with the `request body`.
<br>See: <b><a href="https://gitlab.com/trade-io/official-api-docs/blob/master/sign_request.md">SIGN</a></b>




# Public API Endpoints
## Terminology
* `base asset` refers to the asset that is the `quantity` of a symbol.
* `quote asset` refers to the asset that is the `price` of a symbol.


## ENUM Definitions

**Symbol type:**

* SPOT

**Order status:**

* WORKING
* COMPLETED
* CANCELED

**Order types:**

* LIMIT
* MARKET

**Order side:**

* BUY
* SELL
 

**Kline/Candlestick chart intervals:**

m -> minutes; h -> hours; d -> days; w -> weeks; M -> months

* 1m
* 5m
* 15m
* 30m
* 1h
* 2h
* 4h
* 8h
* 12h
* 1d
* 1w
* 1M

**Rate limits (rateLimitType)**

* WEIGHT
* ORDER

**Rate limit intervals**

* MINUTE
* HOUR
* DAY


## General Endpoints
### Test connectivity and check server time
```
GET /api/v1/time
```
Test connectivity to the Rest API and get the current server time.

**Weight:**
1

**Parameters:**
NONE

**Response:**
```javascript
{
    "code":0, 
    "timestamp":1543950640679, 
    "timezone":"UTC"
}
```

### Exchange Information
```
GET /api/v1/info
```
Current exchange trading rules and symbol information

**Weight:**
1

**Parameters:**
NONE

**Response:**
```javascript
{
  "code": 0,
  "timestamp": 1543950680120,
  "symbols": [
    {
      "symbol": "btnt_tiox",
      "status": "active",
      "baseAsset": "btnt",
      "baseAssetPrecision": 2,
      "quoteAsset": "tiox",
      "quoteAssetPrecision": 6
    },
    {
      "symbol": "bat_tiox",
      "status": "active",
      "baseAsset": "bat",
      "baseAssetPrecision": 6,
      "quoteAsset": "tiox",
      "quoteAssetPrecision": 6
    }
  ]
}
```


## Market Data Endpoints
### Order Book
```
GET /api/v1/depth/{symbol}
```

**Weight:**
Adjusted based on the limit: 1 + (`limit` / 20) 

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | STRING | YES |
limit | INT | NO | Default 10; max 1000

**Caution:** setting limit=0 can return a lot of data.

**Response:**
```javascript
{
  "code": 0,
  "timestamp": 1543951243899,
  "book": {
    "symbol": "btc_usdt",
    "asks": [
      [
        "4300",
        "0.29"
      ],
      [
        "4400",
        "0.4"
      ]
    ],
    "bids": [
      [
        "2000",
        "0.1"
      ],
      [
        "2500",
        "1.5"
      ]
    ]
  }
}
```


### Recent Trades List
```
GET /api/v1/trades/{symbol}
```
Get recent trades (up to last 100).

**Weight:**
Adjusted based on the limit: 1 + (`limit` / 20)

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | STRING | YES |
limit | INT | NO | Default 100; max 100.

**Response:**
```javascript
{
  "code": 0,
  "timestamp": 1543951625536,
  "trades": [
    {
      "symbol": "btc_usdt",
      "time": 1543837852727,
      "id": 0,
      "price": "4300.0",
      "quantity": "0.0100",
      "type": "Buy"
    },
     {
      "symbol": "btc_usdt",
      "time": 1543837851324,
      "id": 0,
      "price": "4310.0",
      "quantity": "0.1100",
      "type": "Buy"
    }
  ]
}
```


### Kline/Candlestick Data
```
GET /api/v1/klines/{symbol}/{interval}
```
Kline/candlestick bars for a symbol.

Klines are uniquely identified by their open time.

**Weight:**

Adjusted based on the limit: 1 + (`limit` / 20)

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | STRING | YES |
interval | ENUM | YES |
startTime | LONG | NO |
endTime | LONG | NO |
limit | INT | NO | Default 500; max 1000.

* If startTime and endTime are not sent, the most recent klines are returned.

**Response:**
```javascript
{
 "code":0,
 "timestamp":1544509124308,
  "candles":[
   {
    "symbol":"btc_usdt",
    "openTime":1543834800000,
    "closeTime":1543838400000,
    "open":"4300",
    "high":"4300",
    "low":"4300",
    "close":"4300",
    "volume":"0.01",
    "tradeCount":0
   }
 ]
}
```

### Symbol Order Book Ticker
```
GET api/v1/ticker/{symbol}
```
Best price/qty on the order book for a symbol or symbols.

**Weight:**
1

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | STRING | YES |

**Response:**
```javascript
{
  "code": 0,
  "timestamp": 1543951974264,
  "ticker": {
    "symbol": "btc_usdt",
    "askPrice": "4300",
    "askQty": "0.29",
    "bidPrice": "1",
    "bidQty": "1",
    "lastPrice": "0.0",
    "lastQty": "0.0",
    "volume": "1.29",
    "quoteVolume": "1248.00",
    "openTime": 0,
    "closeTime": 1543951974344
  }
}
```

### All Symbol Order Book Tickers
```
GET api/v1/tickers
```
Best price/qty on the order book for a symbol or symbols.

**Weight:**
20

**Parameters:**

None

**Response:**
```javascript
{
  "code": 0,
  "timestamp": 1543952473683,
  "tickers": [
    {
      "symbol": "bat_btc",
      "askPrice": "0.0",
      "askQty": "0.0",
      "bidPrice": "0.0",
      "bidQty": "0.0",
      "lastPrice": "0.0",
      "lastQty": "0.0",
      "volume": "0.0",
      "quoteVolume": "0.0",
      "openTime": 0,
      "closeTime": 1543952473777
    },
    {
      "symbol": "bat_eth",
      "askPrice": "0.0",
      "askQty": "0.0",
      "bidPrice": "0.0",
      "bidQty": "0.0",
      "lastPrice": "0.0",
      "lastQty": "0.0",
      "volume": "0.0",
      "quoteVolume": "0.0",
      "openTime": 0,
      "closeTime": 1543952473780
    }
  ]
}
```


## Account Endpoints
### New Order  (TRADE)
```
POST /api/v1/order  (HMAC SHA512)
```
Send in a new order.

**Weight:**
1

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | STRING | YES |
side | ENUM | YES |
type | ENUM | YES |
quantity | DECIMAL | YES |
price | DECIMAL | NO |
stopPrice | DECIMAL | NO | Used with `STOP_LOSS`, `STOP_LOSS_LIMIT`, `TAKE_PROFIT`, and `TAKE_PROFIT_LIMIT` orders.
timestamp | LONG | YES |

**Response RESULT:**
```javascript
{
  "code": 0,
  "timestamp": 1544491464042,
  "order": {
    "orderId": "-72057594037927931",
    "total": "4000.0",
    "orderType": "limit",
    "commission": "0.00100",
    "createdAt": "2018-12-11T01:24:24.0558857Z",
    "unitsFilled": "1.00000000",
    "isPending": true,
    "status": "Working",
    "type": "buy",
    "requestedAmount": "1.50000000",
    "baseAmount": "1.0",
    "quoteAmount": "4000.0",
    "price": "4000.0",
    "isLimit": true,
    "loanRate": "0.0",
    "rateStop": "0.0",
    "instrument": "btc_usdt",
    "requestedPrice": "4000.0",
    "remainingAmount": "0.50000000"
  }
}
```


### Cancel Order (TRADE)
```
DELETE /api/v1/order  (HMAC SHA512)
```
Cancel an active order.

**Weight:**
1

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
orderId | LONG | YEST |

**Response:**
```javascript
{ 
  "code": 0,
  "timestamp": 1544493394903
} 
```



### Current Open Orders (USER_DATA)
```
GET /api/v1/openOrders/{symbol}  (HMAC SHA512)
```
Get all open orders on a symbol. 

**Weight:**
1 

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | STRING | YES |

**Response:**
```javascript
{
  "code": 0,
  "timestamp": 1544494844556,
  "orders": [
    {
      "orderId": "-72057594037927935",
      "total": "0.0",
      "orderType": "limit",
      "commission": "0.0",
      "createdAt": "2018-11-29T07:04:44.6521146Z",
      "unitsFilled": "0.0",
      "isPending": true,
      "status": "Working",
      "type": "buy",
      "requestedAmount": "0.0100",
      "baseAmount": "0.0",
      "quoteAmount": "0.0",
      "price": "0.0100",
      "isLimit": true,
      "loanRate": "0.0",
      "rateStop": "0.0",
      "instrument": "btc_usdt",
      "requestedPrice": "0.0100",
      "remainingAmount": "0.0100"
    }
  ]
}
```

### Current Closed Orders (USER_DATA)
```
GET /api/v1/closedOrders/{symbol}  (HMAC SHA512)
```
Get all closed orders on a symbol. 

**Weight:**
5

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | STRING | YES |
start | long | NO |
end | long | NO |
limit | int | NO | Default 100, max 250

**Response:**
```javascript
{
  "code": 0,
  "timestamp": 1544494844556,
  "orders": [
    {
      "orderId": "-72057594037927935",
      "total": "0.0",
      "orderType": "limit",
      "commission": "0.0",
      "createdAt": "2018-11-29T07:04:44.6521146Z",
      "unitsFilled": "0.0",
      "isPending": false,
      "status": "Completed",
      "type": "buy",
      "requestedAmount": "0.0100",
      "baseAmount": "0.0",
      "quoteAmount": "0.0",
      "price": "0.0100",
      "isLimit": true,
      "loanRate": "0.0",
      "rateStop": "0.0",
      "instrument": "btc_usdt",
      "requestedPrice": "0.0100",
      "remainingAmount": "0.0100"
    }
  ]
}
```


### Account Information (USER_DATA)
```
GET /api/v1/account (HMAC SHA512)
```
Get current account information.

**Weight:**
5

**Parameters:**
NONE

**Response:**
```javascript
{
  "code": 0,
  "timestamp": 1544495473113,
  "balances": [
    {
      "asset": "usdt",
      "available": "999996",
      "locked": "0.0"
    },
    {
      "asset": "ltc",
      "available": "1000000",
      "locked": "0.0"
    },
    {
      "asset": "eth",
      "available": "1000000",
      "locked": "0.0"
    },
    {
      "asset": "bch",
      "available": "1000000",
      "locked": "0.0"
    },
    {
      "asset": "btc",
      "available": "999999.999",
      "locked": "0.0"
    }
  ]
}
```
