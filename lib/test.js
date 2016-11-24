/* eslint-env mocha */
'use strict'

const namemaster = require('../')

describe('namemaster', function () {
  let CONFIG = require('convig').env({
    APIZONE () { throw new Error('need APIZONE, e.g. example.de') },
    APIKEY () { throw new Error('need APIKEY from namemaster') },
    APIUSER () { throw new Error('need APIUSER from namemaster') }
  })

  let client = namemaster(CONFIG.APIUSER, CONFIG.APIKEY, CONFIG.APIZONE)
  let keep = null

  it('should allow fetching domains', function () {
    return client.getHosts()
  })
  it('should allow adding a host', function () {
    return client.setHostAddress('testing', '127.0.0.1').then(function (record) {
      keep = record
    })
  })
  it('should allow an update to the DNS record', function () {
    return client.updateHostAddress('testing', '192.168.1.1', keep.dns_id)
  })
  it('should allow deleting that host', function () {
    return client.deleteHost('testing')
  })
})
