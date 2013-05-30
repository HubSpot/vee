vee
===

Vee is a simple proxy to allow us to develop static js apps locally.

Your project needs to have a `.vee` yaml configuration file (see [example.vee](https://git.hubteam.com/HubSpot/vee/blob/master/example.vee)).  Run
`vee` in that directory and your proxying will begin.

Installation
------------

Assuming you have our npm repo configured:

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
