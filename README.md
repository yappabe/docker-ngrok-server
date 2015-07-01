ngrok-server
============

Create a self signed certificate (docker host)
---------------------------------

    NGROK_DOMAIN="ngrok.yourdomain.com"

    openssl genrsa -out rootCA.key 2048
    openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
    openssl genrsa -out device.key 2048
    openssl req -new -key device.key -subj "/CN=$NGROK_DOMAIN" -out device.csr
    openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000


Building the binaries (docker host)
---------------------

    docker run -it -v /tmp/bin:/ngrok/bin \
        -e CA_CERT="`awk 1 ORS='\\n' rootCA.pem`" \
        yappabe/ngrok-server

Server and client binaries will be available in `/tmp/bin` on the host.

Building the Mac OS X binaries (Mac)
-------------------------------

    git clone https://github.com/inconshreveable/ngrok.git ngrok
    cd ngrok

You should copy the generated certificate to your Mac and place it in `ngrok/assets/client/tls/ngrokroot.crt`

    scp xxx@yourserver:/home/user/rootCA.pem assets/client/tls/ngrokroot.crt
    make release-client
    cp ./bin/ngrok /usr/local/bin/ngrok
    chmod +x /usr/local/bin/ngrok

Running the server (docker host)
------------------

    docker run -d --net host \
        -e TLS_CERT="`awk 1 ORS='\\n' device.crt`" \
        -e TLS_KEY="`awk 1 ORS='\\n' device.key`" \
        -e CA_CERT="`awk 1 ORS='\\n' rootCA.pem`" \
        -e DOMAIN="$NGROK_DOMAIN" \
        yappabe/ngrok-server


Environment Variables
---------------------

    TLS_CERT        TLS cert file for setting up tls connection
    TLS_KEY         TLS key file for setting up tls connection
    CA_CERT         CA cert file for compiling ngrok
    DOMAIN          domain name that ngrok running on
    TUNNEL_ADDR     address that ngrok server's control channel listens to, ":4443" by default
    HTTP_ADDR       address that ngrok server's http tunnel listents to, ":80 by default"
    HTTPS_ADDR      address that ngrok server's https tunnel listents to, ":80 by default"



Client configuration (Mac)
---------------------

    cat >~/.ngrok <<EOL
    server_addr: ngrok.youdomain.com:4443
    trust_host_root_certs: false
    EOL
