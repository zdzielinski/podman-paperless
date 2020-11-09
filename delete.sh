#!/usr/bin/env bash

set -x

CONSUME_DIR=$HOME/Documents/paperless_consume
EXPORT_DIR=$HOME/Documents/paperless_export
SYSTEMD_DIR=$HOME/.config/systemd/user

podman pod stop paperless
podman pod rm paperless

podman volume rm paperless_data
podman volume rm paperless_media

rm -rf $CONSUME_DIR
rm -rf $EXPORT_DIR
rm -rf $SYSTEMD_DIR/podman-paperless.service
systemctl --user daemon-reload
systemctl --user reset-failed