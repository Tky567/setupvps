FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y

RUN apt install --no-install-recommends -y \
    lxqt-core lxqt-panel lxqt-session \
    xorg x11-xserver-utils x11-apps \
    tigervnc-standalone-server \
    novnc websockify \
    sudo curl wget git vim net-tools dbus-x11

RUN apt install -y xfonts-base

# Tạo file cấu hình VNC start LXQT
RUN mkdir -p /root/.vnc && \
    printf "#!/bin/bash\nstartlxqt &\n" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Password VNC mặc định: 123456
RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Link noVNC web frontend
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

EXPOSE 5901
EXPOSE 6080

CMD bash -c "\
vncserver -localhost no -SecurityTypes None -geometry 1280x720 ; \
websockify --web=/usr/share/novnc/ 6080 localhost:5901 ; \
tail -f /dev/null \
"