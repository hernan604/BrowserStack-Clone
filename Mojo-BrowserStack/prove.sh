#!/usr/bin/env bash
#source ../env.sh
#export MOJO_LISTEN="http://*:3000"
export DBIC_TRACE=1
prove -I./lib t
