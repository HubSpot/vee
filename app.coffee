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
  passRedirects: true

commander
  .usage("Run it in the root of your project to start proxying requests as defined in the project's .vee file")
  .option('-p, --port [80]', "Port to serve http requests from.  Comma seperate to bind onto multiple ports.", NumberList)
  .option('-s, --https-port [443]', "Port to serve https requests from (0 to disable).", NumberList)
  .option('-d, --debug', "Output route matching debug info.", Boolean)
  .option('-r, --pass-redirects', "Pass 3XXs to the browser, rather than following them.", Boolean)
  .option('--ssl-key <key>', "SSL private key file to be used with HTTPS requests")
  .option('--ssl-cert <cert>', "SSL certificate file to be used with HTTPS requests")
  .option('-c, --config <config>', 'Specify a configuration file. Defaults to ./.vee', '.vee')
  .parse(process.argv)

watcher = null
watch = (file) ->
  watcher?.close()
  fs.watch file, {persistent: false}, ->
    waitForFileToExist file, ->
      console.log "A config file changed, restarting".yellow
      restart()

waitForFileToExist = (file, callback) ->
  start = +(new Date)
  waitTime = 100
  do checkFile = ->
    fs.exists file, (exists) ->
      if exists
        callback()
      else if +(new Date) - start < waitTime
        setImmediate checkFile
      else
        console.error "configuration file not found within #{waitTime}ms".red
        process.exit(1)

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
  # - Project specific options in ~/.vee.yaml (in a section titled the project's .name property)
  # - Defaults in the system's ~/.vee.yaml (in the `default` section)
  # - Command line flags

  try
    project = loadCfg commander.config
  catch e
    if e.code is 'ENOENT'
      console.error "configuration file not found in the current directory".red
      process.exit(1)
    else
      throw e

  try
    system = loadCfg "#{ process.env.HOME }/.vee.yaml"
  catch e
    throw e unless e.code is 'ENOENT'

  defaults = system?['default'] ? {}

  personal = {}
  if project.name? and system?[project.name]?
    personal = system[project.name]

  options = _.extend {}, DEFAULTS, defaults, project, personal, _.pick(commander, 'port', 'httpsPort', 'debug', 'passRedirects', 'sslKey', 'sslCert')

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
