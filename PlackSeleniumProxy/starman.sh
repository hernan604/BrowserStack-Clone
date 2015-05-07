#!/usr/bin/env bash
source ../env.sh
starman -I../Mojo-BrowserStack-DB/lib/ -I./lib --listen :5555 --workers 32 --preload-app plack.pl
