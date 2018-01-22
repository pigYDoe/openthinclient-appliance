#!/usr/bin/env bash
# Filename:     openthinclient-vnc.sh
# Purpose:      install openthinclient custom VNC server and related packages
#------------------------------------------------------------------------------

INSTALL="apt-get install -y"
UPDATE="apt-get update"
PACKAGES="fluxbox"

eval "$UPDATE"
eval "$INSTALL $PACKAGES"

FBOX_LASTWALLPAPER=/home/openthinclient/.fluxbox/lastwallpaper

echo "==> Installing xvfb with --no-install-recommends"
apt-get install -y --no-install-recommends xvfb

echo "==> Installing x11vnc with --no-install-recommends"
apt-get install -y --no-install-recommends x11vnc

read -r -d '' WALLINCLUDE << EOF
$full $full|/usr/local/share/openthinclient/backgrounds/openthinclient-server-Desktop-Pales.jpg||:22.0
EOF

echo "==> Creating .flubxbox in openthinclient home directory"
mkdir /home/openthinclient/.fluxbox/

echo "==> Including custom wallpaper information for fluxbox "
echo "${WALLINCLUDE}" > ${FBOX_LASTWALLPAPER}

echo "==> Including custom wallpaper information for fluxbox via overlay"
cat > /home/openthinclient/.fluxbox/overlay << EOF
background: aspect
background.pixmap: /usr/local/share/openthinclient/backgrounds/openthinclient-server-Desktop-Pales.jpg
EOF

echo "==> Including custom fluxbox startup file"
cat > /home/openthinclient/.fluxbox/startup << EOF
#fbsetbg -l # sets the last background set, very useful and recommended.
# In the below commands the ampersand symbol (&) is required on all applications that do not terminate immediately.
# Failure to provide them will cause Fluxbox not to start.
/usr/local/bin/openthinclient-manager &
# exec is for starting Fluxbox itself, do not put an ampersand (&) after this or Fluxbox will exit immediately.
exec /usr/bin/fluxbox
# or if you want to keep a log, uncomment the below command and comment out the above command:
#exec /usr/bin/fluxbox -log ~/.fluxbox/log
EOF

chown openthinclient:openthinclient /home/openthinclient/.fluxbox/ -R

echo "==> Configure x11vnc service"
cat > /etc/systemd/system/x11vnc.service << EOF
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
User=openthinclient
Group=openthinclient
Environment="UNIXPW_DISABLE_LOCALHOST=1"
Environment="UNIXPW_DISABLE_SSL=1"
Type=simple
ExecStart=/usr/bin/x11vnc -create -env FD_PROG=/usr/bin/startfluxbox -env X11VNC_FINDDISPLAY_ALWAYS_FAILS=1 -env X11VNC_CREATE_GEOM=${1:-1024x768x16} -forever -unixpw openthinclient

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable x11vnc.service
sudo systemctl daemon-reload


exit 0