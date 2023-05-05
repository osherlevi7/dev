.PHONY: docker-build certbot

docker-build:
		docker build -t ingress .

certbot:
		certbot certonly --manual --preferred-challenges=dns --email osher.levi7777@gmail.com --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d *.domain.com --config-dir ~/Downloads --work-dir ~/Downloads --logs-dir ~/Downloads