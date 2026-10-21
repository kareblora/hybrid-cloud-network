FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    frr \
    frr-pythontools \
    strongswan-starter \
    strongswan-charon \ 
    strongswan-swanctl \
    iproute2 \
    iputils-ping \
    tcpdump \
    traceroute \
    iptables \
    procps \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i \
    -e 's/^zebra=no/zebra=yes/' \
    -e 's/^bgpd=no/bgpd=yes/' \
    /etc/frr/daemons

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
