#!/usr/bin/env bash
source ../env.sh
export MOJO_LISTEN="http://*:8001"
export DBIC_TRACE=1
perl -I../Mojo-BrowserStack-DB/lib/ -I./lib app.pl
