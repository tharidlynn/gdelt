import os
import psycopg2 
from datetime import datetime
import time

from yahoo.crypto import scrape_crypto
from yahoo.commodity import scrape_commodity
from yahoo.currency import scrape_currency
from yahoo.world import scrape_world

def main():
    PG_HOST = os.environ.get('PGHOST')
    PG_USERNAME = os.environ.get('PGUSERNAME')
    PG_PASSWORD = os.environ.get('PGPASSWORD')
    PG_DATABASE = os.environ.get('PGDATABASE')
    
    conn = psycopg2.connect(f'host={PG_HOST} dbname={PG_DATABASE} user={PG_USERNAME} password={PG_PASSWORD}')
    cur = conn.cursor()
    
    while (True):
    
        try: 
            scrape_commodity(cur, conn)
            scrape_currency(cur, conn)
            scrape_crypto(cur, conn)
            scrape_world(cur, conn)

        except psycopg2.Error as e:
            print(e)

        time.sleep(15)

    conn.close()

if __name__ == '__main__':
    main()