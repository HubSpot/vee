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

options = _.pick commander, 'port'

try
  cfg = fs.readFileSync('.vee').toString('utf8')
catch e
  if e.code is 'ENOENT'
    console.error ".vee configuration file not found in the current directory".red
    process.exit(1)
  else
    throw e

try
  project = YAML.parse(cfg)[0]
catch e
  console.error ".vee file is not valid YAML: #{ e.toString() }".red
  process.exit(1)

options.routes = project.routes

proxy.start options

console.log "Proxy started on port #{ options.port }!".green
