FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV XDG_SESSION_TYPE=x11

RUN apt update -y && apt upgrade -y

RUN apt install --no-install-recommends -y \
    lxqt-core lxqt-session lxqt-panel \
    openbox \
    xorg x11-xserver-utils x11-apps \
    tigervnc-standalone-server \
    novnc websockify \
    xauth dbus-x11 \
    sudo curl wget git vim net-tools

RUN apt install -y xfonts-base

# Prepare VNC + LXQt startup
RUN mkdir -p /root/.vnc

RUN printf "#!/bin/bash\n\
export USER=root\n\
export HOME=/root\n\
export DISPLAY=:1\n\
export XAUTHORITY=/root/.Xauthority\n\
export XDG_SESSION_TYPE=x11\n\
touch /root/.Xauthority\n\
eval $(dbus-launch --sh-syntax)\n\
openbox &\n\
lxqt-session &\n\
" > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

# Create noVNC index
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

EXPOSE 5901
EXPOSE 6080

CMD bash -c "\
vncserver -localhost no -SecurityTypes None --I-KNOW-THIS-IS-INSECURE -geometry 1280x720 ; \
websockify --web=/usr/share/novnc/ 6080 localhost:5901 ; \
tail -f /dev/null \
"