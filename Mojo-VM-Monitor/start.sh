#!/usr/bin/env bash
source ../env.sh
export MOJO_LISTEN="http://*:8002"
export DBIC_TRACE=1
perl -I./lib app.pl
