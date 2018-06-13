#!/bin/sh

/usr/lib/rstudio-server/bin/rserver &

sudo -u jupyterhub jupyterhub --config /etc/jupyterhub/jupyterhub_config.py
