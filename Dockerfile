FROM --platform=linux/amd64 debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && \
    apt install -y docker.io curl wget

# Expose WebUI Proxmox fake
EXPOSE 8006

# Khi container này khởi động → nó chạy ngay container Proxmox UI thật
CMD docker run -itd --name proxmoxve --hostname pve \
    -p 8006:8006 --privileged rtedpro/proxmox:8.4.x && \
    tail -f /dev/null