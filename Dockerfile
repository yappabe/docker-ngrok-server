FROM ubuntu:18.04

RUN apt-get update && \
	apt-get install -y build-essential golang git

RUN git clone https://github.com/inconshreveable/ngrok.git /ngrok

ADD scripts/*.sh /

ENV TLS_KEY **None**
ENV TLS_CERT **None**
ENV CA_CERT **None**
ENV DOMAIN **None**
ENV TUNNEL_PORT :4443
ENV HTTP_PORT :80
ENV HTTPS_PORT :443

VOLUME ["/ngrok/bin"]

CMD ["/run-server.sh"]
