FROM ubuntu:16.04
LABEL authors="Attila Bogár <attila.bogar@gmail.com>"

RUN  echo "deb http://archive.ubuntu.com/ubuntu xenial main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main universe\n" >> /etc/apt/sources.list \
  && echo "deb http://security.ubuntu.com/ubuntu xenial-security main universe\n" >> /etc/apt/sources.list

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

# useful packages
RUN apt-get -qqy update \
  && apt-get -y dist-upgrade \
  && apt-get -qqy --no-install-recommends install \
    bzip2 \
    ca-certificates \
    tzdata \
    sudo \
    curl \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# timezone 
ENV TZ "UTC"
RUN echo "${TZ}" > /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata

RUN dpkg --add-architecture i386

# EAC requirement
RUN mkdir /cdrom && echo '/dev/sr0 /cdrom iso9660 noauto 0 0' >> /etc/fstab

# set up X over VNC
RUN apt-get update -qqy \
  && apt-get -qqy install \
    locales \
    xvfb x11vnc \
    openbox obconf lxterminal tint2 menu \
    eject \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#
### WineHQ
#
RUN curl -s -R -L -o /tmp/winehq.key \
  https://dl.winehq.org/wine-builds/winehq.key \
  && apt-key add /tmp/winehq.key \
  && apt-get -qqy update \
  && apt-get -qqy install \
    software-properties-common \
    apt-transport-https \
  && apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ \
  && apt-get -qqy update \
  && apt-get --install-recommends -y install \
    wine-stable=2.0.4~xenial \
    wine-stable-amd64=2.0.4~xenial \
    wine-stable-i386=2.0.4~xenial \
  && rm -rf /tmp/winehq.key /var/lib/apt/lists/* /var/cache/apt/*

#
### builtin wine v1.6
#
#RUN apt-get update -y \
#  && apt-get -y install \
#    wine wine-i386 \
#  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#
# setup openbox
#
COPY openbox/autostart openbox/menu.xml \
  /etc/xdg/openbox/
COPY tint2/tint2rc.custom /etc/xdg/tint2/

# entry point
COPY entry_point.sh /
COPY session.sh /

CMD ["/entry_point.sh"]
