FROM containrrr/watchtower:latest as parent

FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:alpine as google

FROM python:3-alpine as served

LABEL "com.centurylinklabs.watchtower"="true"

RUN apk update && apk add --no-cache bash docker ca-certificates tzdata

EXPOSE 8080

COPY --from=google /google-cloud-sdk /usr/lib/google-cloud-sdk

COPY --from=parent /watchtower /watchtower

ENV PATH $PATH:/usr/lib/google-cloud-sdk/bin

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

COPY gcr_docker_login.sh /usr/local/bin/gcr_docker_login.sh

RUN chmod u+x /usr/local/bin/entrypoint.sh /usr/local/bin/gcr_docker_login.sh

ADD crontab.txt /crontab.txt

RUN /usr/bin/crontab /crontab.txt

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
