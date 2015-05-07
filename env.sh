#!/usr/bin/env bash
BROWSERSTACK_ENV_CUSTOM='env_custom.sh'
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BROWSERSTACK_CUSTOM_ENV="$DIR/$BROWSERSTACK_ENV_CUSTOM"
if [[ -e $BROWSERSTACK_CUSTOM_ENV ]];
    then
   #XXX=$(cat $BROWSERSTACK_CUSTOM_ENV)
   #$XXX
    source $BROWSERSTACK_CUSTOM_ENV
else
    export BROWSERSTACK_DSN="postgresql://hernan:@/browserstack"
    export BROWSERSTACK_MIGRATIONS="/home/hernan/p/browser-stack/v3/Mojo-BrowserStack-DB/migrations.sql"
    export BROWSERSTACK_CONFIG="/home/hernan/p/browser-stack/v3/config.pl"
    export BROWSERSTACK_QUEUE_SESSION_START="session_start"
    export BROWSERSTACK_DIR_SCREENSHOT="/home/hernan/p/browser-stack/v3/Mojo-BrowserStack/public/v1/live-screenshot/"
fi
