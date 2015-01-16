vee
===

Vee is a simple proxy to to develop static js apps locally.  It allows you to forward traffic to various services or folders on your machine or the internet based on the url requested.

It's different than other options, because the proxy configuration is read from the project (like a package.json), not a central file on your machine.

Your project needs to have a `.vee` yaml configuration file (see [example.vee](https://github.com/HubSpot/vee/blob/master/example.vee)).  Run
`vee` in that directory and your proxying will begin.

Add the `--debug` option to see each route as it matches.

Getting Started
------------

#### 1. Install vee

```bash
npm install -g vee
```

#### 2. Save a `.vee` file in the root of your project, with whatever routing you might need:

```yaml
name: "my-app"
routes:
  ".*/static/": "http://localhost:3333"
  ".*": "http://localhost:8081/"
```

#### 3. Run vee to start proxing in that directory

```bash
sudo vee
```

.vee files
----------

Your .vee file should define a mapping between a regular expression to match the url
requested and a host to send the request to.

If the host ends with a slash ('/'), the passed in path will be appended to it, if it
does not, the request will be forward to the exact page provided.  Note that YAML has
it's own escaping, so if you need to use the escape character ('\') in your regular
expressions, use it twice ('\\\\').

See above for an example .vee file.

Static files
------------

vee can also serve static files for you.  Just start the target in your .vee file with
the `file://` protocol.

HTTPS
-----

vee will by default attach to port 80 for HTTP traffic and port 443 for HTTPS traffic.
vee includes some self-signed certs which should be just good enough for you to be
able to use HTTPS locally (but should never be trusted to secure anything).

If you would like to disable https, pass `-s 0`, or set `httpsPort: 0` in your config
file.

System Configuration
--------------------

You can define a `~/.vee.yaml` file to set defaults for vee's command line flags
and routes.  For example, your vee.yaml file could contain:

```yaml
default:
  debug: true
  port: 7
  routes:
    "google/.*": "http://google.com/"
contacts-ui:
  port: 8888
```

Multiple Configurations
-----------------------

You may want to have multiple configuration files within the same project, in order to allow different proxying rules depending on the envirnoment you are working on (e.g. local vs QA). You can specify a custom config file by using the `--config` flag as follows:

```bash
sudo vee --config .vee.qa
```
