#!/bin/sh
# -*- tcl -*- \
exec kettle -f "$0" "${1+$@}"
kettle critcl3
kettle tcl
