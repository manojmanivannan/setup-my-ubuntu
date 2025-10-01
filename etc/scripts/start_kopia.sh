#!/bin/bash

source ~/.config/kopia/env_var

kopia server start \
    --tls-cert-file ~/.config/kopia/my.cert \
    --tls-key-file ~/.config/kopia/my.key \
    --address="https://0.0.0.0:51515" \
    --server-control-username="$KOPIA_SERVER_CONTROL_USER" \
    --server-control-password="$KOPIA_SERVER_CONTROL_PASSWORD" \
    --server-username="$KOPIA_SERVER_USERNAME" \
    --server-password="$KOPIA_SERVER_PASSWORD" \
    --disable-csrf-token-checks \
    --shutdown-grace-period=60s #--tls-generate-cert

# use --tls-generate-cert if running for first time
#
# ~ $ cat /etc/systemd/system/kopia.service
# [Unit]
# Description=Kopia Start
# After=network.target
#
# [Service]
# ExecStart=/home/manoj/.local/bin/start_kopia.sh
# Restart=always
# RestartSec=15
# User=manoj
# WorkingDirectory=/home/manoj
# StandardOutput=journal
# StandardError=journal
#
# [Install]
# WantedBy=multi-user.target
#
# ~ $ sudo systemctl daemon-reload
# ~ $ sudo systemctl enable myscript.service
# ~ $ sudo systemctl start myscript.service
#
# some reference: https://github.com/DoTheEvo/selfhosted-apps-docker/tree/master/kopia_backup#Kopia-in-Linux
