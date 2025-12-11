FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y

RUN apt install --no-install-recommends -y \
    lxqt-core lxqt-session lxqt-panel \
    openbox \
    xorg x11-xserver-utils x11-apps \
    tigervnc-standalone-server \
    novnc websockify \
    sudo curl wget git vim net-tools dbus-x11 xauth

RUN apt install -y xfonts-base

# =============================
# Tạo user GUI
# =============================
RUN useradd -m -s /bin/bash gui && echo "gui:gui" | chpasswd && adduser gui sudo
RUN mkdir -p /home/gui/.vnc && chown -R gui:gui /home/gui

USER gui
ENV HOME=/home/gui
ENV SHELL=/bin/bash
ENV DISPLAY=:1
ENV XAUTHORITY=/home/gui/.Xauthority
RUN touch /home/gui/.Xauthority

# =============================
# XSTARTUP CHUẨN LXQt
# =============================
RUN printf "#!/bin/bash\n\
export USER=gui\n\
export HOME=/home/gui\n\
export DISPLAY=:1\n\
export XAUTHORITY=/home/gui/.Xauthority\n\
eval \$(dbus-launch --sh-syntax)\n\
openbox &\n\
lxqt-session &\n\
" > /home/gui/.vnc/xstartup && chmod +x /home/gui/.vnc/xstartup

USER root

# =============================
# Link noVNC front-end
# =============================
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

EXPOSE 5901
EXPOSE 6080

# =============================
# CMD: chạy VNC dưới USER + websockify
# =============================
CMD bash -c "\
sudo -u gui vncserver -localhost no -SecurityTypes None --I-KNOW-THIS-IS-INSECURE -geometry 1366x768 ; \
websockify --web=/usr/share/novnc/ 6080 localhost:5901 \
"