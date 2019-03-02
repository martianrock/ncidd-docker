ARG NCID_VERSION=1.10.1
ARG ARCH=amd64

FROM phusion/baseimage as downloader
ARG NCID_VERSION
ARG ARCH
WORKDIR /root
RUN export DEBIAN_FRONTEND=noninteractive &&\ 
    apt-get update -qq && \
    apt-get install -y --no-install-recommends wget && \
    /usr/sbin/update-ca-certificates --fresh && \
    cd /root && \
    wget https://downloads.sourceforge.net/project/ncid/ncid/${NCID_VERSION}/ncid_${NCID_VERSION}-1_${ARCH}.deb

FROM phusion/baseimage
ARG NCID_VERSION
ARG ARCH
WORKDIR /root
COPY --from=downloader /root/ncid_${NCID_VERSION}-1_${ARCH}.deb /root
RUN export DEBIAN_FRONTEND=noninteractive &&\
    cd /root && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends perl netcat-traditional tzdata && \
    dpkg -i ncid_${NCID_VERSION}-1_${ARCH}.deb && \
    apt-get install -f -y --no-install-recommends &&\
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* && \
    cp -R /etc/ncid /root/ncid-conf-default && \
    mkdir /etc/service/ncidd && \
    echo "#!/bin/bash\nexec /usr/sbin/ncidd -D -L /dev/null 2>&1" > /etc/service/ncidd/run && \
    chmod +x /etc/service/ncidd/run && \
    echo "#!/bin/bash\n[ \"\$(ls -A /etc/ncid)\" ] && echo \"Not rebuilding ncid config directory\" || (echo \"Rebuilding default ncid config\" && mkdir -p /etc/ncid && cp -R /root/ncid-conf-default/* /etc/ncid)" > /etc/my_init.d/00_rebuild_ncid_config && \
    chmod +x /etc/my_init.d/00_rebuild_ncid_config

HEALTHCHECK --interval=1m --timeout=10s \
    CMD echo "HELLO: IDENT: docker-healthcheck-client\nHELLO: CMD: no_log\nGOODBYE\n" | nc 127.0.0.1 3333 | grep ncidd || exit 1
