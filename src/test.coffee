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
  
  it "should allow fetching domains", () ->
    client.getHosts()
  it "should allow adding a host", () ->
    client.setHostAddress("testing", "127.0.0.1")
  it "should allow deleting that host", () ->
    client.deleteHost("testing")
