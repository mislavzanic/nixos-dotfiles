#!/bin/sh

curr=$(mpc current | awk 'BEGIN { FS = "/"; } {print $NF;}' | awk 'BEGIN {FS = ".";} {print $1;}')
[[ "$curr" ]] && echo "🎹$curr"
