import time
import sys
import random
import psycopg2
from coolname import generate

credentials = {
    "old": "host=127.0.0.1 port=15432 dbname=super-service user=mega-user password=secret-password",
    "new": "host=127.0.0.1 port=15433 dbname=super-service user=mega-user password=secret-password",
}

def usage():
    print("usage: python3 worker.py <instance>")
    print("  instance may be `old` or `new`")
    sys.exit(1)
    

if len(sys.argv) != 2:
    usage()

instance = sys.argv[1]
if instance != 'old' and instance != 'new':
    usage()

dsn = credentials[instance]

conn = psycopg2.connect(dsn)

while True:
    cur = conn.cursor()

    # select random parent record and create from 1 to 3 child records for it
    cur.execute("SELECT * FROM parent ORDER BY RANDOM() LIMIT 1")
    parent_record = cur.fetchone()
    if parent_record is not None:
        print("loaded parent record: {id=\"%s\", name=\"%s\"}" % parent_record)
        for i in range(random.randint(1,3)):
            child_record = (
                parent_record[0],
                " ".join(generate())
            )
            cur.execute("INSERT INTO child (parent_id, name) values (%s, %s) RETURNING id", child_record)
            ret = cur.fetchone()
            print("created child record: {id=\"%s\", parent=\"%s\", name=\"%s\"}" % (ret[0], child_record[0], child_record[1]))

    # generate a new parent record
    name = " " . join(generate())
    cur.execute("INSERT INTO parent (name) VALUES (%s)", (name,))
    conn.commit()

    print("")
    time.sleep(1)
