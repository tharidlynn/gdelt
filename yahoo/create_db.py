import os
import psycopg2 

def create_database():

    PG_HOST = os.environ.get('PGHOST')
    PG_USERNAME = os.environ.get('PGUSERNAME')
    PG_PASSWORD = os.environ.get('PGPASSWORD')
    PG_DEFAULT_DATABASE = os.environ.get('PGDEFAULTDATABASE')
    PG_DATABASE = os.environ.get('PGDATABASE')
    
    conn = psycopg2.connect(f'host={PG_HOST} dbname={PG_DEFAULT_DATABASE} user={PG_USERNAME} password={PG_PASSWORD}')
    conn.set_session(autocommit=True)
    cur = conn.cursor()

    cur.execute(f'DROP DATABASE IF EXISTS {PG_DATABASE};')
    cur.execute(f'CREATE DATABASE {PG_DATABASE};')
    
    conn.close()    
    print(f'{PG_DATABASE} database has been created')
    
    # connect to yahoo_finance database
    conn = psycopg2.connect(f'host={PG_HOST} dbname={PG_DATABASE} user={PG_USERNAME} password={PG_PASSWORD}')
    cur = conn.cursor()
    
    return cur, conn


def create_tables(cur, conn):

    create_crypto_table = """ CREATE TABLE crypto (
        id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        name TEXT,
        price DOUBLE PRECISION,
        change DOUBLE PRECISION,
        percent_change DOUBLE PRECISION,
        market_cap TEXT,
        total_volume TEXT,
        circulate_supply TEXT,
        ts TIMESTAMPTZ
    );  """

    create_world_table = """ CREATE TABLE world (
        id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        name TEXT,
        price DOUBLE PRECISION,
        change DOUBLE PRECISION,
        percent_change DOUBLE PRECISION,
        volume TEXT,
        ts TIMESTAMPTZ
    );  """

    create_currency_table = """CREATE TABLE currency (
        id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        name TEXT,
        price DOUBLE PRECISION,
        change DOUBLE PRECISION,
        percent_change DOUBLE PRECISION,
        ts TIMESTAMPTZ
    );  """

    create_commodity_table = """ CREATE TABLE commodity (
        id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        name TEXT,
        price DOUBLE PRECISION,
        market_time TEXT,
        change DOUBLE PRECISION,
        percent_change DOUBLE PRECISION,
        volume INTEGER,
        open_interest INTEGER,
        ts TIMESTAMPTZ
    );  """

    create_table_queries = [create_crypto_table, create_world_table, create_currency_table, create_commodity_table]
    for query in create_table_queries:
        cur.execute(query)
        conn.commit()
        print('CREATE TABLE')



def main():
    cur, conn = create_database()

    try:
        create_tables(cur, conn)
   
    except psycopg2.Error as e:
        print(e)

    conn.close()

        
if __name__ == '__main__':
    main()
