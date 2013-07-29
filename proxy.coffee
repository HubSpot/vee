colors = require('colors')
http = require('http')
request = require('request')
domain = require('domain')
URL = require('url')
_ = require('underscore')

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

  server = http.createServer()
  server.on 'request', (req, res) ->
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

    headers = _.omit req.headers, 'host'

    options =
      uri: url
      method: req.method
      headers: headers

    reqDomain.run ->
      request(options).pipe res

  server.listen(config.port)

module.exports = {start}
