_ = require('underscore')
YAML = require('libyaml')
colors = require('colors')
fs = require('fs')
commander = require('commander')

proxy = require('./proxy')

commander
  .usage("Run it in the root of your project to start proxying requests as defined in the project's .vee file")
  .option('-p, --port [port number]', "port to run from", 80)
  .option('-d, --debug', "Output route matching debug info", false)
  .parse(process.argv)

loadCfg = (file) ->
  cfg = fs.readFileSync(file).toString('utf8')

  try
     return YAML.parse(cfg)[0]
  catch e
    console.error "#{ file } file is not valid YAML: #{ e.toString() }".red
    process.exit(1)

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

options = _.extend {}, system, _.pick(commander, 'port', 'debug')

options.routes ?= {}
_.extend options.routes, project.routes

proxy.start options

console.log "Proxy started on port #{ options.port }!".green
