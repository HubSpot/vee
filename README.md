vee
===

Vee is a simple proxy to allow us to develop static js apps locally.

Your project needs to have a `.vee` yaml configuration file (see [example.vee](https://git.hubteam.com/HubSpot/vee/blob/master/example.vee)).  Run
`vee` in that directory and your proxying will begin.

Add the `--debug` option to see each route as it matches.

Requirements
------------

If you do not have our npm repo configured, you want to use the workstation_setup fab npm call to set up npm. This will install node and npm and set our private repo in the settings.

You should also install nvm, to manage versions

https://github.com/creationix/nvm

if you run the setup script for nvm it will add the initialization to a .bash_profile or .profile instead of .zshrc. you'll need to copy the initialization into your .zshrc and source it if this is not to your liking.

Installation
------------

Ensure you're running/ pointing at node 0.8.15, then

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

You can define a `~/.hubspot/vee.yaml` file to set defaults for vee's command line flags
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

### Ohh... IE!

Just in case you can't figure out why IE9 isn't working with your local vee setup, you'll likely need something like this in your routes:

```
  "^/(proxy-api|proxy-intapi|proxy-login)": "https://app.hubspotqa.com/"
```

... because IE9 doesn't (really) support CORs, we need to proxy it. So if you don't have those proxy URLs routed as well HapiJS will always 404 when making an api-verify request.

Also, if you didn't already realize, you'll need to be hitting a **https://**local.hubspotqa.com/... URL for IE9 to work (since otherwise the HTTP only & secure cookies won't be used). To do that you'll need to have vee proxying port 443 (which it does by default) and if using browserstack, you'll need to make sure that you proxy port 443 as well.
