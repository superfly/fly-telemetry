#!/bin/sh

/victoria-metrics-prod -envflag.enable &
/victoria-logs-prod -envflag.enable &
vector -c vector-dest.yml
