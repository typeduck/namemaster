'use strict'

const Promise = require('bluebird')
const Request = require('request')

module.exports = (u, p, z, t) => new ZoneManager(u, p, z, t)

class ZoneManager {
  constructor (uname, pass, zone, ttl) {
    this.zone = zone
    this.ttl = ttl || 1800
    this.requester = Promise.promisifyAll(Request.defaults({
      baseUrl: 'http://api.domainclient.de/api.php',
      method: 'GET',
      qs: {
        simulation: 0,
        antwort: 'key',
        user: uname,
        password: pass,
        zone: this.zone
      }
    }))
  }
  setTTL (ttl) {
    this.ttl = ttl
  }
  getHosts () { return this.request({action: 'List_IN'}) }
  deleteHost (host) {
    return this.request({action: 'Delete_IN', typ: 'A', hostname: `${host}.${this.zone}`})
  }
  setHostAddress (host, ipv4) {
    let qs = {}
    qs.action = 'Create_IN'
    qs.typ = 'A'
    qs.hostname = `${host}.${this.zone}`
    qs.adresse = ipv4
    qs.TTL = this.ttl
    // Catch special situation of existing already, delete and re-create
    return this.request(qs).catch((err) => {
      if (err.code !== 40) {
        throw err
      }
      return this.deleteHost(host).then(() => this.request(qs))
    })
  }
  updateHostAddress (host, ipv4, dnsId) {
    let qs = {}
    qs.action = 'Update_IN'
    qs.typ = 'A'
    qs.hostname = `${host}.${this.zone}`
    qs.adresse = ipv4
    qs.TTL = this.ttl
    qs.dns_id = dnsId
    return this.request(qs)
  }
  request (qs) {
    return this.requester.getAsync({uri: '', qs}).then(function (res) {
      let answer = {}
      res.body.split(/\r\n|\r|\n/g).forEach(addLine, answer)
      if (answer.fehler) {
        throw createError(answer)
      } else {
        return answer
      }
    })
  }
}

// HELPER FUNCTION, parses the Namemaster response into an object
const intKeys = {fehler: 1, dns_id: 1, simulation: 1, 'int': 1}
function addLine (s) {
  let writeTo = this.tmpObj || this
  if (s.match(/=/)) {
    s = s.split('=')
    let k = s.shift().toLowerCase().replace('-', '_')
    let v = s.shift()
    writeTo[k] = k in intKeys ? parseInt(v, 10) : v
  } else if (s.match(/\[dnsid_info_start\]/i)) {
    this.records = []
  } else if (s.match(/\[record\]/i)) {
    this.records.push(this.tmpObj = {})
  } else if (s.match(/\[dnsid_info_ende\]/i)) {
    delete this.tmpObj
  }
}

// HELPER FUNCTION, hopefully not needed!
function createError (answer) {
  let e = new Error(answer.description)
  e.code = answer.fehler
  e.data = answer
  return e
}
