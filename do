#!/bin/bash

set -eux

export PGDATABASE=postgres

for PGVERSION in ${*:-10 9.6 9.5 9.4}; do
	echo
	echo "### $PGVERSION ###"
	PG_CONFIG=/usr/lib/postgresql/$PGVERSION/bin/pg_config
	export PGCLUSTER="$PGVERSION/main"
	export PGPORT="54${PGVERSION/./}"
	[ "$PGVERSION" = "9.6" ] && unset PGPORT # default version

	make clean
	make PG_CONFIG=$PG_CONFIG PROFILE="-Werror"
	sudo make install PG_CONFIG=$PG_CONFIG
	psql -c "DROP EXTENSION IF EXISTS numbers CASCADE"
	#psql -c "CREATE EXTENSION IF NOT EXISTS numbers"
	if ! make installcheck REGRESS_OPTS="--use-existing --dbname=postgres" PG_CONFIG=$PG_CONFIG; then
		cat regression.diffs
		exit 1
	fi
done
