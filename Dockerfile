FROM --platform=linux/amd64 debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt full-upgrade -y

RUN hostnamectl set-hostname pve.local
RUN echo "127.0.1.1 pve.local pve" >> /etc/hosts

# Add Proxmox repository
RUN echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" \
    > /etc/apt/sources.list.d/pve-install-repo.list

RUN wget -qO- https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg

RUN apt update -y

# Install Proxmox VE core packages
RUN apt install -y proxmox-ve postfix open-iscsi chrony

# Remove enterprise repo
RUN rm -f /etc/apt/sources.list.d/pve-enterprise.list

RUN apt update -y

# Enable Proxmox services
RUN systemctl enable pvedaemon
RUN systemctl enable pve-cluster
RUN systemctl enable pve-manager

# Restart Proxmox services
RUN systemctl restart pvedaemon
RUN systemctl restart pve-cluster
RUN systemctl restart pve-manager

# Expose Proxmox management UI & SSH (style-matching original Dockerfile)
EXPOSE 8006
EXPOSE 22