# hello-http

A docker image for a hello world webserver, featuring a trusted localhost ssl certificate for http/https, and using http/2 and brotli compression.
Useful for testing api gateways and load-balancing functionality.

### Setup
``` bash
> run.cmd
```

#### Notes
Ensure a `localhost` SSL certificate has been setup.
``` sh
> dotnet dev-certs https --trust
```
