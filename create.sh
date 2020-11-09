#!/usr/bin/env bash

set -x

CONSUME_DIR=$HOME/Documents/paperless_consume
EXPORT_DIR=$HOME/Documents/paperless_export
SYSTEMD_DIR=$HOME/.config/systemd/user

mkdir -p $CONSUME_DIR $EXPORT_DIR $SYSTEMD_DIR

podman volume create paperless_data
podman volume create paperless_media

podman pod create --name paperless \
    -p 127.0.0.1:8000:8000

podman run -td -v paperless_data:/usr/src/paperless/data/ -v paperless_media:/usr/src/paperless/media/ \
    -v $CONSUME_DIR:/consume/:Z \
    --env-file paperless.env -e PAPERLESS_OCR_LANGUAGES= \
    --name paperless_webserver --pod paperless localhost/paperless:latest \
    gunicorn -b 0.0.0.0:8000

# allow the webserver to create required database tables first
sleep 5

podman run -td -v paperless_data:/usr/src/paperless/data/ -v paperless_media:/usr/src/paperless/media/ \
    -v $CONSUME_DIR:/consume/:Z \
    -v $EXPORT_DIR:/export/:Z \
    --env-file paperless.env \
    --name paperless_consumer --pod paperless localhost/paperless:latest \
    document_consumer

# let things sync in for a few seconds
sleep 10

# stop the pod for now
podman pod stop paperless

# sync some more because errors and stuff
sleep 5

cp -f podman-paperless.service $SYSTEMD_DIR/podman-paperless.service

# let systemd take the reigns
systemctl --user daemon-reload
systemctl --user reset-failed
systemctl --user start podman-paperless