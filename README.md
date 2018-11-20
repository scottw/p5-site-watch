# site-watch

A high-concurrency, configuration-driven http/https website status checker.

## Note

This is under active development (alpha quality): the syntax or output may change at any time. If you have a particular request (check the [Planned Features](#planned_features) and [To Do](#to_do) lists below), I'd be eager to hear about it (see [Contact](#contact) below).

<a name="usage"></a>
## Usage

One site only:

```sh
./site-watch --name "my site" --url https://example.com --request_timeout=5
```

One or more sites:

```sh
./site-watch --config my-sites.yaml
```

where `my-sites.yaml` looks like:

```yaml
sites:
  - name: 'site 1'
    url: 'http://www.site1.com'
    request_timeout: 5
  - name: 'site 2'
    url: 'https://site2.net'
  - name: 'site 3'
    url: 'http://bogus.site'
    request_timeout: 0.750
```

The `request_timeout` setting is in seconds; fractional seconds down to millisecond resolution is acceptable. This setting is optional and defaults to '10' (10 seconds).

<a name="output"></a>
## Output

The output will be a CSV file:

```
"name","time","is ok","latency","error"
"site 1",1542742987,1,0.124502,""
"site 2",1542742987,1,0.299601,""
"site 3",1542742987,0,0.167750,"Can't connect: nodename nor servname provided, or not known"
```

<a name="docker"></a>
## Docker

One site only, pass NAME and URL (and optional REQUEST_TIMEOUT) as environment variables:

```sh
docker run --rm --env NAME="my site" --env URL=http://example.com  scottw/site-watch:latest
```

One or more sites, mount a YAML configuration file at `/app/etc/site-watch.yaml`:

```sh
docker run --rm --mount type=bind,source=$(pwd)/my-sites.yaml,target=/app/etc/site-watch.yaml scottw/site-watch:latest
```

<a name="development"></a>
## Development

To build the docker image:

```sh
make build
```

For local development, use [Carton](https://metacpan.org/pod/Carton) to install and manage dependencies:

```sh
carton install
carton exec -- prove -lvr t
```

<a name="planned_features"></a>
## Planned Features

Some additional work I plan to do, already have modeling for but haven't exposed via the application yet:

- [ ] allow a simple "up" check (web server responds with a status code)
- [ ] allow alternative status codes when deciding if a site is "ok" (e.g., 204, etc.)
- [ ] follow HTTP redirects (up to a specified number)
- [ ] allow CSS selector-based content checking
- [ ] allow for other HTTP methods (currently HEAD)

<a name="to_do"></a>
## To Do

Here is the current wishlist:

- [ ] multiple output formats (json, yaml, csv, text, etc.)
- [ ] set concurrency limits

<a name="contact"></a>
## Contact

Scott Wiersdorf, <scott@perlcode.org>
