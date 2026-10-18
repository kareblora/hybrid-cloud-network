# Build docker container
docker build -t hybrid-router:1.0 .

docker run --rm -it --entrypoint /bin/bash hybrid-router:1.0

# Inside the container
cat /etc/os-release

command -v vtysh
vtysh --version

command -v ipsec
ipsec version

dpkg -l | grep -E 'frr|strongswan'

# Deploying and verifying router containers

docker compose up -d
docker ps

docker exec router-a ip -br address
docker exec router-b ip -br address
