FROM debian:bullseye-slim
# Create a non-root user with no password and add them to the fuse group
RUN useradd -r -s /usr/sbin/nologin -g fuse fuseuser
RUN apt-get update -qqq && \
    apt-get install -qqq -y curl fuse && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV GCS_FUSE_VERSION=0.41.4
RUN curl -sS -L -O https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v${GCS_FUSE_VERSION}/gcsfuse_${GCS_FUSE_VERSION}_amd64.deb &&\
 dpkg --install gcsfuse_${GCS_FUSE_VERSION}_amd64.deb &&\
 rm -rf gcsfuse_${GCS_FUSE_VERSION}_amd64.deb
# Drop privileges and switch to non-root user
USER fuseuser
ENTRYPOINT ["gcsfuse"]