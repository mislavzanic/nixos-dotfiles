#!/usr/bin/env bash
skripte="/home/mzanic/.local/pmf/skripte"
ls $skripte | sed -E "s/\s/_/g;" | awk -v prefix="$skripte/" '{print prefix $0}'
