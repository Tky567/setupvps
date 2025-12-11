FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

RUN apt update -y && apt upgrade -y

RUN apt install --no-install-recommends -y \
    lxqt-core lxqt-session lxqt-panel \
    xorg x11-xserver-utils x11-apps \
    tigervnc-standalone-server \
    novnc websockify \
    sudo curl wget git vim net-tools dbus-x11

RUN apt install -y xfonts-base

# Create user
RUN useradd -m -s /bin/bash gui && echo "gui:gui" | chpasswd && adduser gui sudo
RUN chown -R gui:gui /home/gui

USER gui
ENV HOME=/home/gui

RUN mkdir -p /home/gui/.vnc
RUN printf "#!/bin/bash\nstartlxqt &\n" > /home/gui/.vnc/xstartup && chmod +x /home/gui/.vnc/xstartup

USER root

RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Railway uses dynamic port
EXPOSE 8080

CMD bash -c "\
sudo -u gui vncserver -localhost no -SecurityTypes None -geometry 1280x720 && \
websockify --web=/usr/share/novnc/ $PORT localhost:5901 \
"