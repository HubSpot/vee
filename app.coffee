_ = require('underscore')
yaml = require('js-yaml')
colors = require('colors')
fs = require('fs')
commander = require('commander')

proxy = require('./proxy')

commander
  .usage("Run it in the root of your project to start proxying requests as defined in the project's .vee file")
  .option('-p, --port [80]', "port to serve http requests from", Number, 80)
  .option('-s, --https-port [443]', "port to serve https requests from (0 to disable)", Number, 443)
  .option('-d, --debug', "Output route matching debug info", Boolean, false)
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
  # - Defaults in the system's ~/.hubspot/vee.yaml (in the `default` section)
  # - Project specific options in ~/.hubspot/vee.yaml (in a section titled the project's .name property)
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

  options = _.extend defaults, project, personal, _.pick(commander, 'port', 'httpsPort', 'debug')

  options.httpPort = options.port
  delete options.port

  options.routes = _.extend {}, defaults.routes, project.routes, personal.routes

  proxy.start options

stop = ->
  proxy.stop()

restart = ->
  stop()
  start()

start()
