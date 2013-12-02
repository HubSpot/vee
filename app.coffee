_ = require('underscore')
yaml = require('js-yaml')
colors = require('colors')
fs = require('fs')
commander = require('commander')

proxy = require('./proxy')

NumberList = (str) ->
  str.split(',').map(Number)

DEFAULTS =
  port: 80
  httpsPort: 443
  passRedirects: false

commander
  .usage("Run it in the root of your project to start proxying requests as defined in the project's .vee file")
  .option('-p, --port [80]', "Port to serve http requests from.  Comma seperate to bind onto multiple ports.", NumberList)
  .option('-s, --https-port [443]', "Port to serve https requests from (0 to disable).", NumberList)
  .option('-d, --debug', "Output route matching debug info.", Boolean)
  .option('-r, --pass-redirects', "Push 3XXs to the browser (default, vee follows them)", Boolean)
  .parse(process.argv)

watch = (file) ->
  fs.watch file, {persistent: false}, ->
    console.log "A config file changed, restarting".yellow
    restart()

loadCfg = (file) ->
  cfg = fs.readFileSync(file).toString('utf8')

  watch file

  try
    return yaml.safeLoad(cfg)
  catch e
    console.error "Config file at #{ file } is not valid YAML: #{ e.toString() }".red
    process.exit(1)

start = ->
  # Options can come from four sources:
  #
  # - The project's .vee file
  # - Project specific options in ~/.hubspot/vee.yaml (in a section titled the project's .name property)
  # - Defaults in the system's ~/.hubspot/vee.yaml (in the `default` section)
  # - Command line flags

  try
    project = loadCfg '.vee'
  catch e
    if e.code is 'ENOENT'
      console.error ".vee configuration file not found in the current directory".red
      process.exit(1)
    else
      throw e

  try
    system = loadCfg "#{ process.env.HOME }/.hubspot/vee.yaml"
  catch e
    throw e unless e.code is 'ENOENT'

  defaults = system?['default'] ? {}

  personal = {}
  if project.name? and system?[project.name]?
    personal = system[project.name]

  options = _.extend {}, DEFAULTS, defaults, project, personal, _.pick(commander, 'port', 'httpsPort', 'debug', 'passRedirects')

  options.httpPort = options.httpPort ? options.port
  delete options.port

  unless _.isArray options.httpPort
    options.httpPort = [options.httpPort]

  if options.httpsPort and not _.isArray options.httpsPort
    options.httpsPort = [options.httpsPort]

  #this will ensure that it goes through the project routes FIRST, before personal, then defaults (stepped through by
  #insertion order). `_.defaults` was used so personal don't overwrite project routes and default routes don't overwrite
  #project or personal routes.
  options.routes = _.extend {}, project.routes
  _.defaults options.routes, personal.routes
  _.defaults options.routes, defaults.routes

  proxy.start options

stop = ->
  proxy.stop()

restart = ->
  stop()
  start()

start()
