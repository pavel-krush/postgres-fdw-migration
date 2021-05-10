import time
import sys
import random
import psycopg2
import time
from coolname import generate


dsn = "host=127.0.0.1 port=15433 dbname=super-service user=mega-user password=secret-password"

def usage():
    print("usage: python3 migrator.py <table> <batch-size>")
    print("  batch-size must be between 1 and 100000")
    sys.exit(1)

if len(sys.argv) != 3:
    usage()

local_table = sys.argv[1]
remote_table = local_table + "_remote"
batch_size = int(sys.argv[2])

if batch_size < 1 or batch_size > 100000:
    usage()

conn = psycopg2.connect(dsn)
records_migrated = 0
last_reported = time.time()
report_interval = 5 # report amount of migrated records every 5 seconds

while True:
    # report if needed
    now = time.time()
    if now - last_reported > report_interval:
        last_reported = now
        print("%d records migrated" % records_migrated)

    cur = conn.cursor()

    # copy batch of data into temporary table and save amount of copied items
    cur.execute("SELECT * INTO TEMPORARY __migration_temp FROM " + remote_table + " LIMIT %s", (batch_size,))
    cur.execute("SELECT count(*) from __migration_temp")
    count = cur.fetchone()[0]

    # insert records to the local table and delete them from the remote table
    cur.execute("INSERT INTO " + local_table + " SELECT * FROM __migration_temp")
    cur.execute("DELETE FROM " + remote_table + " WHERE id IN (SELECT id FROM __migration_temp)")

    # drop temporary table and commit transaction
    cur.execute("DROP TABLE __migration_temp")
    conn.commit()

    records_migrated += count

    if count < batch_size:
        break

print("%d records migrated" % records_migrated)
