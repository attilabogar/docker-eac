#!/bin/bash
set -euxo pipefail

function setup_user() {
  groupadd --non-unique --gid $GID user
  useradd user \
         --shell /bin/bash  \
         --create-home \
         --non-unique --uid $UID --gid $GID
  usermod -a -G sudo user
  echo 'Defaults env_keep += "NODE SCREEN_WIDTH SCREEN_HEIGHT"' >> /etc/sudoers
  echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers
  echo 'user:user' | chpasswd
  echo 'export PS1="[$NODE \W]\$"' >> /home/user/.profile
  echo 'export PATH="/opt/wine-stable/bin:${PATH}"' >> /home/user/.profile
}

getent passwd user > /dev/null || setup_user

# cdrom uid/gid
[ -b /dev/sr0 ] && chown user:user /dev/sr0

sudo --user=user --set-home /session.sh
