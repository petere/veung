#!/bin/bash

# This script runs the PostgreSQL regression tests, captures
# auto_explain output in a CSV log file, extracts the JSON, and runs
# the results through veung.  This basically just checks that the
# format doesn't crash veung, it doesn't check that the results are
# reasonable, but the result files are left around for manual
# inspection.
#
# To run, certain environment variables should be set:
#
# PGSRC  PostgreSQL source tree
# PATH   Add PostgreSQL bin directory if necessary, and path to veung program
#
# An integer argument can optionally be passed, which limits the
# output to plans with at least that many nodes, to weed out the
# trivial plans.  (3 is a good start.)

set -eux
set -o pipefail

PGDATA=$(mktemp -d --tmpdir veung-test.XXXXXX)
export PGDATA

trap "set +e; pg_ctl stop -w; rm -rf $PGDATA" EXIT

workdir=$PWD/output
mkdir -p "$workdir"
rm -f "$workdir"/*.{json,png}

initdb
cat <<EOF >>$PGDATA/postgresql.conf
fsync = off
log_destination = 'csvlog'
logging_collector = on
log_filename = 'postgresql.log'
shared_preload_libraries = 'auto_explain'
auto_explain.log_min_duration = 0
auto_explain.log_format = json
EOF
pg_ctl start -w

make -C "$PGSRC" installcheck

pg_ctl stop -w

cd "$workdir"
python ../pg_csvlog_to_json.py "$@" < $PGDATA/pg_log/postgresql.csv
for file in *.json; do
	echo $file
	veung -o - < $file | dot -Tpng -o ${file%.json}.png
done
