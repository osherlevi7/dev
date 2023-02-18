FROM debian:bullseye-slim

RUN apt-get update -qqq && apt-get install -qqq -y curl fuse

ENV GCS_FUSE_VERSION=0.41.4

RUN curl -sS -L -O https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v${GCS_FUSE_VERSION}/gcsfuse_${GCS_FUSE_VERSION}_amd64.deb &&\
 dpkg --install gcsfuse_${GCS_FUSE_VERSION}_amd64.deb &&\
 rm -rf gcsfuse_${GCS_FUSE_VERSION}_amd64.deb

ENTRYPOINT ["gcsfuse"]

# test
#
