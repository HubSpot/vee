vee
===

Vee is a simple proxy to allow us to develop static js apps locally.

Your project needs to have a `.vee` yaml configuration file (see [example.vee](https://github.com/HubSpot/vee/blob/master/example.vee)).  Run
`vee` in that directory and your proxying will begin.

Add the `--debug` option to see each route as it matches.

Installation
------------

```bash
npm install -g vee
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
