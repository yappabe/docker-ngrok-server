FROM ubuntu:18.04

RUN apt-get update && \
	apt-get install -y build-essential golang git

RUN git clone https://github.com/inconshreveable/ngrok.git /ngrok

ADD scripts/*.sh /

ENV TLS_KEY **None**
ENV TLS_CERT **None**
ENV CA_CERT **None**
ENV DOMAIN **None**
ENV TUNNEL_ADDR :4443
ENV HTTP_ADDR :80
ENV HTTPS_ADDR :443

VOLUME ["/ngrok/bin"]

CMD ["/run-server.sh"]
