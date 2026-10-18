# Operating system
cat /etc/os-release

# Docker installation and daemon
docker --version
docker info

# Docker Compose
docker compose version

# Available resources
free -h
df -h /

# Existing network interfaces and routes
ip -br address
ip route

# Existing Docker networks and containers
docker network ls
docker ps -a


