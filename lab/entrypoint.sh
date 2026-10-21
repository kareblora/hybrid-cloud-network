#!/bin/bash
set -Eeuo pipefail

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

: "${UNDERLAY_IF:?UNDERLAY_IF must be set}"
: "${XFRM_IF:=ipsec0}"
: "${XFRM_ID:=42}"
: "${XFRM_ADDR:?XFRM_ADDR must be set}"
: "${IPSEC_CONNECTION:?IPSEC_CONNECTION must be set}"
: "${IPSEC_CHILD:=routed-tunnel}"

# Verify the underlay interface exists.
if ! ip link show dev "$UNDERLAY_IF" >/dev/null 2>&1; then
    log "ERROR: Underlay interface $UNDERLAY_IF does not exist."
    exit 1
fi

# Create the XFRM interface only if it does not already exist.
if ! ip link show dev "$XFRM_IF" >/dev/null 2>&1; then
    log "Creating XFRM interface $XFRM_IF (ID $XFRM_ID)"
    ip link add "$XFRM_IF" type xfrm \
        if_id "$XFRM_ID" dev "$UNDERLAY_IF"
else
    log "XFRM interface $XFRM_IF already exists"
fi

# Configure its address and bring it up.
ip address replace "$XFRM_ADDR" dev "$XFRM_IF"
ip link set "$XFRM_IF" up

# Enable IPv4 forwarding for routed traffic.
sysctl -w net.ipv4.ip_forward=1

# Start strongSwan using the starter/stroke service.
log "Starting strongSwan"
ipsec start

# Wait for the VICI interface to become available.
VICI_READY=0
for attempt in $(seq 1 30); do
    if swanctl --list-conns > /dev/null 2>&1; then
        VICI_READY=1
        break
    fi
    sleep 2
done

if [ "$VICI_READY" -ne 1 ]; then
    log "ERROR: strongSwan VICI interface did not become ready"
    exit 1
fi

# Load connection definitions and credentials from swanctl.conf.
log "Loading IPsec connections and credentials"
swanctl --load-conns 2> /dev/null
swanctl --load-creds 2> /dev/null

# Start FRR.
log "Starting FRRouting"
service frr start

# Initiate the configured CHILD SA, retrying while the peer starts.
log "Checking whether the IPsec CHILD SA is already established"

if swanctl --list-sas --ike "$IPSEC_CONNECTION" 2>/dev/null \
    | grep -Fq "$IPSEC_CHILD"; then
    log "IPsec CHILD SA '$IPSEC_CHILD' already exists; skipping initiation"
else
    log "Initiating IPsec CHILD SA '$IPSEC_CHILD'"

    IPSEC_READY=0

    for attempt in $(seq 1 10); do
        if swanctl --initiate \
            --ike "$IPSEC_CONNECTION" \
            --child "$IPSEC_CHILD" \
            --timeout 30 2> /dev/null ; then
            IPSEC_READY=1
            break
        fi

        # Check whether the CHILD SA was established despite
        # the command returning a non-zero status.
        if swanctl --list-sas --ike "$IPSEC_CONNECTION" 2>/dev/null \
            | grep -Fq "$IPSEC_CHILD"; then
            IPSEC_READY=1
            break
        fi

        log "IPsec initiation attempt $attempt failed; retrying in 5 seconds"
        sleep 5
    done

    if [ "$IPSEC_READY" -ne 1 ]; then
        log "WARNING: IPsec CHILD SA was not confirmed during startup"
        log "Inspect with: swanctl --list-sas"
    fi
fi

log "Bootstrap complete; keeping container running"
exec sleep infinity

