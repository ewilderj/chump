#!/bin/bash
#
# adjust CHUMP_BASE to where it's installed
CHUMP_BASE=/usr/local/lib/dailychump
$CHUMP_BASE/dailychumptwist.py ${1+"$@"}
