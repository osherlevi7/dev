FROM centos:centos8

EXPOSE 25

VOLUME ["/var/log", "/var/spool/postfix"]

RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum updateinfo -y && \
    yum update -y glibc && \
    yum install -y python3 postfix cyrus-sasl cyrus-sasl-plain mailx && \
    yum clean all

RUN python3 -m pip install chaperone
RUN python3 -m pip install pyyaml==5.4.1

RUN mkdir -p /etc/chaperone.d
COPY chaperone.conf /etc/chaperone.d/chaperone.conf

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh

ENTRYPOINT ["/usr/local/bin/chaperone"]