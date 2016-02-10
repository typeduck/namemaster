###############################################################################
# Partial implementation of the Namemaster.de API for DNS
###############################################################################

Promise = require("bluebird")
Request = require("request")

module.exports = (u, p, z, t) -> new ZoneManager(u, p, z, t)

class ZoneManager
  constructor: (uname, pass, @zone, @ttl = 1800) ->
    @requester = Promise.promisifyAll(Request.defaults({
      baseUrl: "http://api.domainclient.de/api.php"
      method: "GET"
      qs: {
        simulation: 0
        antwort: "key"
        user: uname
        password: pass
        zone: @zone
      }
    }))
  # Set TTL for future requests
  setTTL: (@ttl) ->

  # A-Record management
  getHosts: () -> @request({action: "List_IN"})
  deleteHost: (host) ->
    @request({action: "Delete_IN", typ: "A", hostname: "#{host}.#{@zone}"})
  setHostAddress: (host, ipv4) ->
    qs = {}
    qs.action = "Create_IN"
    qs.typ = "A"
    qs.hostname = "#{host}.#{@zone}"
    qs.adresse = ipv4
    qs.TTL = @ttl
    # Catch special situation of existing already, delete and re-create
    @request(qs).catch((err) =>
      if err.code isnt 40
        throw err
      @deleteHost(host).then(() => @request(qs) )
    )

  # Parses the key/value pairs into data object
  request: (qs) ->
    @requester.getAsync({uri: "", qs: qs}).then((res) ->
      data = res.body
      data.split(/\r\n|\r|\n/g).forEach(addLine, answer = {})
      if answer.fehler
        throw createError(answer)
      else
        return answer
    )

# HELPER FUNCTION, parses the Namemaster response into an object
intKeys = fehler: 1, dns_id: 1, simulation: 1, "int": 1
addLine = (s) ->
  writeTo = @tmpObj || @
  if s.match /\=/
    [k, v] = s.split("=")
    k = k.toLowerCase()
    writeTo[k] = if k of intKeys then parseInt(v, 10) else v
  else if s.match(/\[dnsid_info_start\]/i)
    @records = []
  else if s.match /\[record\]/i
    @records.push( @tmpObj = {} )
  else if s.match /\[dnsid_info_ende\]/i
    delete @tmpObj

# HELPER FUNCTION, hopefully not needed!
createError = (answer) ->
  e = new Error(answer.description)
  e.code = answer.fehler
  e.data = answer
  return e
