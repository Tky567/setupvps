FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y

RUN apt install --no-install-recommends -y \
    lxqt-core lxqt-session lxqt-panel \
    xorg x11-xserver-utils x11-apps \
    tigervnc-standalone-server \
    novnc websockify \
    sudo curl wget git vim net-tools dbus-x11

RUN apt install -y xfonts-base

# Prepare VNC configuration
RUN mkdir -p /root/.vnc && \
    printf "#!/bin/bash\nstartlxqt &\n" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Link noVNC index
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

EXPOSE 5901
EXPOSE 6080

CMD bash -c "\
vncserver -localhost no -SecurityTypes None --I-KNOW-THIS-IS-INSECURE -geometry 1280x720 ; \
websockify --web=/usr/share/novnc/ 6080 localhost:5901 ; \
tail -f /dev/null \
"