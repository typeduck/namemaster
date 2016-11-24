# namemaster

Client for Namemaster API. This client library uses bluebird Promises as its
return values.

## Create client for a zone

Create a client for a given zone.

```javascript
const namemaster = require('namemaster')
let client = namemaster('username', 'apiKey', 'example.de')
```

## client.setTTL

Set [TTL](https://en.wikipedia.org/wiki/Time_to_live) for requests.

```javascript
client.setTTL(3600) // TTL for records
```

## client.getHosts

Query the hosts in the zone. As per the Namemaster API, if you use the value
'ALL' as the zone name, this call will return records for all your zones.

```javascript
client.getHosts().then(function (answer) {
  answer.records.forEach(function (record) {
    console.log(record.typ)      // 'A', 'MX', 'C', 'SPF', 'TXT'
    console.log(record.dns_id)   // namemaster internal ID
    console.log(record.hostname) // e.g. 'subdomain.example.de'
    console.log(record.ip)       // e.g. '127.0.0.1' (A records)
    console.log(record.alias)    // e.g. 'server.example.de' (C records)
    console.log(record.spf)      // e.g. 'v=spf1 a mx -all' (SPF records)
    console.log(record.txt)      // e.g. 'google-site-verification=...' (TXT records)
  })
})
```

## client.setHostAddress

Create or set an A record for a host.

```javascript
client.setHostAddress('subdomain', '127.0.0.1').then(function (answer) {
  console.log(answer.result) // 'Success'
  console.log(answer.fehler) // 0
})
```

## client.deleteHost

Delete a host A record.

```javascript
client.deleteHost('subdomain').then(function (answer) {
  console.log(answer.result) // 'Success'
  console.log(answer.fehler) // 0
})
```
