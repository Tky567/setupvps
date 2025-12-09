FROM --platform=linux/amd64 debian:12

ENV DEBIAN_FRONTEND=noninteractive

# Update và cài Docker bên trong image
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y docker.io curl wget

# Tạo container Proxmox FAKE khi image chạy
RUN mkdir -p /proxmox-start

# Script khởi động Proxmox UI container
RUN printf "#!/bin/bash\n\
docker rm -f proxmoxve >/dev/null 2>&1 || true\n\
docker run -itd --name proxmoxve --hostname pve \\\n\
  -p 8006:8006 --privileged rtedpro/proxmox:8.4.x\n\
docker logs proxmoxve\n\
tail -f /dev/null\n" > /proxmox-start/start.sh

RUN chmod +x /proxmox-start/start.sh

# Mở port giống như bản của bạn
EXPOSE 8006

# Khi container được chạy → start Proxmox UI container bên trong
CMD ["/proxmox-start/start.sh"]