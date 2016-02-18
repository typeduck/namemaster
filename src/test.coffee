###############################################################################
# Tests for Namemaster client, requires API setup
###############################################################################

Promise = require("bluebird")
namemaster = require("./namemaster")

describe "namemaster", () ->

  CONFIG = require("convig").env({
    APIZONE: () -> throw new Error("need APIZONE, e.g. example.de")
    APIKEY: () -> throw new Error("need APIKEY from namemaster")
    APIUSER: () -> throw new Error("need APIUSER from namemaster")
  })

  client = null
  before () ->
    client = namemaster(CONFIG.APIUSER, CONFIG.APIKEY, CONFIG.APIZONE)
  # Keeping data between tests
  keep = null
  
  it "should allow fetching domains", () ->
    client.getHosts()
  it "should allow adding a host", () ->
    client.setHostAddress("testing", "127.0.0.1").then((record) ->
      keep = record
    )
  it "should allow an update to the DNS record", () ->
    client.updateHostAddress("testing", "192.168.1.1", keep.dns_id)
  it "should allow deleting that host", () ->
    client.deleteHost("testing")
