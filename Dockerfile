FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y

# ----------------------
# Cài LXQT Desktop + VNC + noVNC
# ----------------------
RUN apt install --no-install-recommends -y \
    lxqt-core lxqt-session lxqt-panel \
    xorg x11-xserver-utils x11-apps \
    tigervnc-standalone-server \
    novnc websockify \
    sudo curl wget git vim net-tools dbus-x11

# ----------------------
# Tạo user "gui" giống như file Docker GUI gốc tạo user để chạy VNC
# ----------------------
RUN useradd -m -s /bin/bash gui && echo "gui:gui" | chpasswd && adduser gui sudo

USER gui
ENV HOME=/home/gui

# ----------------------
# Chuẩn bị thư mục VNC
# ----------------------
RUN mkdir -p /home/gui/.vnc

# Script chạy LXQT khi VNC start
RUN printf "#!/bin/bash\nstartlxqt &\n" > /home/gui/.vnc/xstartup && \
    chmod +x /home/gui/.vnc/xstartup

USER root

# noVNC web page
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

EXPOSE 5901
EXPOSE 6080

# ----------------------
# CMD — y hệt file Docker GUI gốc
# ----------------------
CMD bash -c "\
sudo -u gui vncserver -localhost no -SecurityTypes None -geometry 1280x720 ; \
websockify --web=/usr/share/novnc/ 6080 localhost:5901 ; \
tail -f /dev/null \
"