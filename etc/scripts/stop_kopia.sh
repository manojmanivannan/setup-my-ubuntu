#!/bin/bash

source ~/.config/kopia/env_var

kopia server shutdown \
    --address "https://0.0.0.0:51515" \
    --server-control-username="$KOPIA_SERVER_CONTROL_USER" \
    --server-control-password="$KOPIA_SERVER_CONTROL_PASSWORD" \
    --server-cert-fingerprint="$KOPIA_SERVER_CERT_FINGERPRINT" > /dev/null 2>&1 || true

