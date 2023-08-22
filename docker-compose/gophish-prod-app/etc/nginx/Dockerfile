FROM nginx:latest

RUN apt update

RUN apt install -y \
    python3-acme \
    python3-certbot \
    python3-mock \
    python3-openssl \
    python3-pkg-resources \
    python3-pyparsing \
    python3-zope.interface

RUN apt install python3-certbot-nginx

# RUN rm /etc/nginx/conf.d/default.conf

COPY config.conf /etc/nginx/conf.d/
# Generate a self-signed certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=examples.com"

CMD ["nginx", "-g", "daemon off;"]