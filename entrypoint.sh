#!/bin/bash -e
. /esp/esp-idf/export.sh
. /esp/esp-matter/export.sh
exec "$@"
exit 0
