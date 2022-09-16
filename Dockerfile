FROM ubuntu:20.04

ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive 

# Install packages
RUN apt-get update
RUN apt-get -yy upgrade

ENV BUILD_DEPS="git autoconf pkg-config libssl-dev libpam0g-dev \
    libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex \
    bison libxml2-dev dpkg-dev libcap-dev"
RUN apt-get -yy install  sudo apt-utils software-properties-common $BUILD_DEPS
# Install apt-utils
RUN apt-get install -y apt-utils

FROM nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04
ARG ADDITIONAL_PACKAGES=""
ENV ADDITIONAL_PACKAGES=${ADDITIONAL_PACKAGES}

ENV DEBIAN_FRONTEND noninteractive

# Install the required packages for desktop
RUN apt update && apt -y full-upgrade && apt-get install -y \
      supervisor \
      xvfb \
      xfce4 \
      x11vnc \
    # Install utilities(optional).
      wget \
      curl \
      net-tools \
      xfce4-clipman-plugin \
      xfce4-cpugraph-plugin \
      xfce4-netload-plugin \
      xfce4-screenshooter \
      xfce4-screensaver \
      xfce4-power-manager \
      xfce4-taskmanager \
      xfce4-terminal \
      xfce4-xkb-plugin \      
    # Install others
      firefox \
      locales \
      openssh-server \
      pepperflashplugin-nonfree \
      pulseaudio \
      uuid-runtime \
      vim \
      xauth \
      xautolock \
      sudo \
      git \
      wget \
      p7zip-full \
      htop \
      curl \
      python3 \
      python3-dev \
      python3-pip \
      libjpeg-dev \
      libgl1-mesa-glx \
      libglib2.0-0 \
      libsm6 \
      libxrender-dev \
      libxext6 \
      && \
    # Clean up
    apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install noVNC
RUN mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "http://github.com/novnc/noVNC/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/novnc/websockify/tarball/master" | tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

RUN cp -r /etc/ssh /ssh_orig && \
  rm -rf /etc/ssh/*
 
VOLUME ["/etc/ssh","/home"]
EXPOSE 8080 22 9001
COPY supervisord/* /etc/supervisor/conf.d/
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

RUN apt update && apt-get install fonts-droid-fallback ttf-wqy-zenhei ttf-wqy-microhei fonts-arphic-ukai fonts-arphic-uming -y
