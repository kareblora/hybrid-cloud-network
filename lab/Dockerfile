FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    frr \
    frr-pythontools \
    strongswan-starter \
    iproute2 \
    iputils-ping \
    tcpdump \
    traceroute \
    iptables \
    procps \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Enable Zebra and BGP for the router containers.
RUN sed -i 's/^bgpd=no/bgpd=yes/' /etc/frr/daemons

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
