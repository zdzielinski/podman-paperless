#!/usr/bin/env bash

set -x

podman exec -it paperless_webserver ./manage.py createsuperuser