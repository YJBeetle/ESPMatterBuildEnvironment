#!/bin/bash -e
. $IDF_PATH/export.sh
. $MATTER_PATH/export.sh
exec "$@"
