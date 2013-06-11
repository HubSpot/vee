_ = require('underscore')
YAML = require('libyaml')
colors = require('colors')
fs = require('fs')
commander = require('commander')

proxy = require('./proxy')

commander
  .usage("Run it in the root of your project to start proxying requests as defined in the project's .vee file")
  .option('-p, --port [80]', "port to run from")
  .option('-d, --debug', "Output route matching debug info")
  .parse(process.argv)

loadCfg = (file) ->
  cfg = fs.readFileSync(file).toString('utf8')

  try
     return YAML.parse(cfg)[0]
  catch e
    console.error "Config file at #{ file } is not valid YAML: #{ e.toString() }".red
    process.exit(1)

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

options = _.extend {port: 80, debug: false}, defaults, project, personal, _.pick(commander, 'port', 'debug')

options.routes = _.extend {}, defaults.routes, project.routes, personal.routes

proxy.start options

console.log "Proxy started on port #{ options.port }!".green
