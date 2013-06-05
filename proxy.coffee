colors = require('colors')
url = require('url')
http = require('http')
Proxy = require('http-proxy')

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

  parseTarget = (dest) ->
    parts = url.parse(dest)

    return {
      host: parts.hostname
      port: parts.port
      path: parts.path
    }

  server = Proxy.createServer (req, res, proxy) ->
    target = getTarget(req)

    unless target
      res.writeHead(404)
      res.end("Proxying target not found")
      return

    target = parseTarget(target)

    unless target.path[target.path.length - 1] == '/'
      req.url = target.path

    proxy.proxyRequest req, res, target

  server.listen(config.port)

module.exports = {start}
