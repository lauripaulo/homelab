#!/bin/bash
# This script is used to recover the database from a backup file.
# It decompresses the backup file, modifies the search path in the SQL commands,
# and then restores the database using the modified SQL commands.
# Usage: ./recover-db.sh
# https://immich.app/docs/administration/backup-and-restore/

docker compose down -v  # CAUTION! Deletes all Immich data to start from scratch

## Uncomment the next line and replace DB_DATA_LOCATION with your Postgres path to permanently reset the Postgres database
## CAUTION! Deletes all Immich data to start from scratch
rm -rf /srv/main-raid/photos/immich/postgres

docker compose pull             # Update to latest version of Immich (if desired)
docker compose create           # Create Docker containers for Immich apps without running them
docker start immich_database    # Start Postgres server
sleep 10                        # Wait for Postgres server to start up
# Check the database user if you deviated from the default

gunzip --stdout "/srv/external-usb/backup-rsync/postgresql-db-immich/dump-immich-2025-05-15.sql.gz" \
| sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
| docker exec -i immich_database psql --dbname=postgres --username=postgres  # Restore Backup

docker compose up -d 

# To backup the database, run the following command:
# docker exec -t immich_database pg_dumpall --clean --if-exists --username=postgres | gzip > "/srv/external-usb/backup-rsync/postgresql-db-immich/dump-immich-$(date +%Y-%m-%d).sql.gz"
