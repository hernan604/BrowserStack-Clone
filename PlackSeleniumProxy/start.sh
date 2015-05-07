#!/usr/bin/env bash
source ../env.sh
plackup -r -p 5555 -I../Mojo-BrowserStack-DB/lib/ -I./lib plack.pl
