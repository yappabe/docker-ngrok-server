# ngrok-server

This repository gathers scripts, instructions and a `Dockerfile` to help setting up [`ngrok`](https://ngrok.com) on your own server and domain!! (So excited!!)

Most of the instructions come from [this amazing post](https://www.svenbit.com/2014/09/run-ngrok-on-your-own-server/).


## Requirements

- [`docker`](https://www.docker.com/)
- Access to a computer with ip publicly available.
- A domain you can change the DNS configuration.


## Client and Server

There are 2 pieces of software you will need to be able to use `ngrok` on your own server: `ngrok` and `ngrokd`.

`ngrok` is the client, the software you will run on the computer you want to expose to the internet. If you have a server running at `http://localhost:8080` and you want to make it publicly available, you need to run the client.

`ngrokd` is the server, the software you will probably run on someone else computer (aka cloud) with a publicly available ip address.


## Building the docker image

You can use an already built docker image or build it yourself.

To pull a built image from docker hub, run:

```bash
docker pull murilopolese/ngrok-server
```

If you want o build yourself, you can run:

```bash
docker build -t yourname/ngrok-server:version .
```


## Generating self signed certificates

`ngrok` requires you to bake a SSL certificate on the "client" and run the "server" specifying which certificates it's expecting.

You can sign your certificate with the respective authorities or sign it yourself. If you choose to do it yourself, run the following command:

```bash
docker run -v $(pwd)/certificate:/certificate \
    -e DOMAIN="tunnel.yourdomain.com" \
    murilopolese/ngrok-server \
    ./generate_certificates.sh
```

**IMPORTANT**: If you want to create urls like `something.tunnel.yourdomain.com`, you have to specify the `DOMAIN` to be `tunnel.yourdomain.com`. If you want to create urls like `something.yourdomain.com`, set `DOMAIN` to `yourdomain.com`. Later on I will show how to configure your DNS but it's important to create the signature correctly.

After this you will have a `certificate` folder on your repository folder. But as `docker` has created those files you will need to claim their ownership with:

```
sudo chown $USER certificate/*
```


## Building the binaries (Ubuntu 18.04)

Once you have generated (or gathered) your SSL certificate you can build the binaries with:

```bash
docker run -v $(pwd)/bin:/ngrok/bin \
    -e TLS_CERT="`awk 1 ORS='\\n' certificate/device.crt`" \
    -e TLS_KEY="`awk 1 ORS='\\n' certificate/device.key`" \
    -e CA_CERT="`awk 1 ORS='\\n' certificate/rootCA.pem`" \
    -e DOMAIN="tunnel.yourdomain.com" \
    murilopolese/ngrok-server \
    ./build.sh
```

This will create a `bin` folder on your repository folder with `ngrok` and `ngrokd`. In order to be able to execute them run the following commands (use `sudo` if needed):

```bash
chown $USER bin
chown $USER bin/*
chmod +x bin/ngrok
chmod +x bin/ngrokd
```

If you are planning to use the built client, remember to create an `ngrok` config file specifying where is your server. For example a `.ngrok` on the `bin` folder. The contents should be:

```
server_addr: tunnel.yourdomain.com:4443
trust_host_root_certs: false
```

So to expose your `localhost:8080` as `something.tunnel.yourdomain.con` you would run do something like:

```bash
cd bin
./ngrok -hostname=something.tunnel.yourdomain -config=./ngrok.cfg 8080
```

## Building the binaries on other OS

Follow [`ngrok` development instructions](https://github.com/inconshreveable/ngrok/blob/master/docs/DEVELOPMENT.md)


## Configuring DNS

In order to make this work you will need to use a computer with a publicly available ip. Once you know this ip, go to whatever you manage your DNS and create an `A` record pointing to this ip.

So if you want to create your urls as `something.tunnels.yourdomain.com`, you should set your DNS records to be something like this:

| TYPE | NAME      | VALUE   |
|------|-----------|---------|
|  A   | *.tunnel  | 0.0.0.0 |

**IMPORTANT**: Change the `0.0.0.0` for the public ip of the computer you are running the "server". If you want your urls being created as `something.yourdomain.com`, change `*.tunnels` to `*`.


## Running the server inside Docker

```bash
docker run -d --net host \
    -e TLS_CERT="`awk 1 ORS='\\n' certificate/device.crt`" \
    -e TLS_KEY="`awk 1 ORS='\\n' certificate/device.key`" \
    -e CA_CERT="`awk 1 ORS='\\n' certificate/rootCA.pem`" \
    -e DOMAIN="tunnel.yourdomain.com" \
    murilopolese/ngrok-server \
    ./run-server.sh
```


## Running the client inside Docker

```bash
docker run --net host \
    -e TLS_CERT="`awk 1 ORS='\\n' certificate/device.crt`" \
    -e TLS_KEY="`awk 1 ORS='\\n' certificate/device.key`" \
    -e CA_CERT="`awk 1 ORS='\\n' certificate/rootCA.pem`" \
    -e DOMAIN="tunnel.yourdomain.com" \
    murilopolese/ngrok-server \
    ./run-client.sh -hostname=something.tunnel.yourdomain.com -config=/root/.ngrok 8080
```

**IMPORTANT**: Remember to switch `tunnel.yourdomain.com` by your domain. This example assumes you have a server running on `localhost:8080`.


## Environment Variables

```
TLS_CERT        TLS cert file for setting up tls connection
TLS_KEY         TLS key file for setting up tls connection
CA_CERT         CA cert file for compiling ngrok
DOMAIN          domain name that ngrok running on
TUNNEL_PORT     port that ngrok server's control channel listens to, ":4443" by default
HTTP_PORT       port that ngrok server's http tunnel listents to, ":80 by default"
HTTPS_PORT      port that ngrok server's https tunnel listents to, ":80 by default"
```
