FROM debian:bullseye
LABEL authors="Attila Bogár <attila.bogar@gmail.com>"

ENV WINEHQ_VERSION=6.0.4~bullseye-1

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

# useful packages
RUN apt-get -qqy update \
  && apt-get -y dist-upgrade \
  && apt-get -qqy --no-install-recommends install \
    gpg gpg-agent \
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
  && gpg --batch --no-default-keyring --keyring /tmp/winehq_signing_key_temp.gpg --import /tmp/winehq.key \
  && gpg --batch --no-default-keyring --keyring /tmp/winehq_signing_key_temp.gpg --export > /etc/apt/trusted.gpg.d/winehq.gpg \
  && rm -f /tmp/winehq.key /tmp/winehq_signing_key_temp.gpg \
  && apt-get -qqy update \
  && apt-get -qqy install \
    software-properties-common \
    apt-transport-https \
  && apt-add-repository https://dl.winehq.org/wine-builds/debian/ \
  && apt-get -qqy update \
  && apt-get --install-recommends -y install \
    wine-stable=${WINEHQ_VERSION} \
    wine-stable-i386=${WINEHQ_VERSION} \
    wine-stable-amd64=${WINEHQ_VERSION} \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

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
COPY entrypoint.sh /
COPY session.sh /

CMD ["/entrypoint.sh"]
