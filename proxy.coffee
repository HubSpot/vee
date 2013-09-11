colors = require('colors')
http = require('http')
https = require('https')
request = require('request')
domain = require('domain')
fs = require('fs')
URL = require('url')
_ = require('underscore')

server = null

start = (config) ->
  match = (url, route) ->
    new RegExp(route).test(url)

  debug = (args...) ->
    if config.debug
      console.log args...

  getTarget = (req) ->
    debug "Proxying request to #{ req.url }"
    for path, dest of config.routes
      debug "Trying #{ path }"

      if match(req.url, path)
        debug "#{ path } matches, sending to #{ dest }".green
        return dest

    debug "No match!".red

  handle = (req, res) ->
    reqDomain = domain.create()

    target = getTarget(req)

    reqDomain.on 'error', (err) ->
      console.log 'Error Proxying!'.red
      console.log 'Request:', req?.url
      console.log 'Target:', target
      console.log err?.code or err

      res.writeHead 502
      res.end "vee error proxying: #{ err?.code or err }"

    unless target
      res.writeHead 404
      res.end "Proxying target not found"
      return

    url = target
    if target[target.length - 1] is '/'
      url += URL.parse(req.url).path.replace(/^\//, '')

    options =
      uri: url
      method: req.method
      headers: req.headers

    reqDomain.run ->
      req.pipe(request(options)).pipe res

  server = http.createServer()
  server.on 'request', handle

  if config.httpsPort
    # The key is included in the public git repo, this is in no way secure
    httpsServer = https.createServer
      key: fs.readFileSync "#{ __dirname }/keys/vee.key"
      cert: fs.readFileSync "#{ __dirname }/keys/vee.crt"

    httpsServer.on 'request', handle

  lDomain = domain.create()
  lDomain.on 'error', (err) ->
    switch err?.code
      when 'EACCES'
        console.log "Permissions issue binding to port #{ config.httpPort } or #{ config.httpsPort }".red
        console.log "Perhaps you need to run vee as root? (sudo vee)"
        console.log "Or use the -p/-s flags to start vee on ports above 1024"
        process.exit(1)
      when 'EADDRINUSE'
        console.log "It seems that port #{ config.httpPort } or #{ config.httpsPort } is already in use".red
        console.log "Please terminate the processes bound to those ports, or use the -p/-s flags to start vee on different ports"
        process.exit(1)

    throw err

  lDomain.run ->
    console.log "Proxy starting:"
    console.log "  http on #{ config.httpPort }".green
    if config.httpsPort
      console.log "  https on #{ config.httpsPort }".green

    server.listen(config.httpPort)
    httpsServer.listen(config.httpsPort)

stop = ->
  server?.close()

module.exports = {start, stop}
