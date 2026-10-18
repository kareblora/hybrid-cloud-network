# Run host containers for connectivity tests
docker run -d \
  --name host-a \
  --network lab_lan-a \
  --ip 10.10.10.10 \
  --cap-add NET_ADMIN \
  alpine:3.20 sleep infinity

docker run -d \
  --name host-b \
  --network lab_lan-b \
  --ip 10.40.0.10 \
  --cap-add NET_ADMIN \
  alpine:3.20 sleep infinity

# Installing iputils in host containers for ping tests
docker exec host-a apk add --no-cache iputils
docker exec host-b apk add --no-cache iputils

# Configuring static routes in host containers to reach each other through the routers
docker exec host-a ip route add 10.40.0.0/24 via 10.10.10.2
docker exec host-b ip route add 10.10.10.0/24 via 10.40.0.2
