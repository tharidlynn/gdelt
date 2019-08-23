import requests
import bs4
import psycopg2 
from datetime import datetime

def scrape_world(cur, conn):
    target_url = 'https://finance.yahoo.com/world-indices'
    res = requests.get(target_url)
    page = bs4.BeautifulSoup(res.content, 'html.parser')

    names = [name.text for name in page.find_all('td', class_='data-col1')]
    prices = [float(price.text.replace(',', '')) for price in page.find_all('td', class_='data-col2')]
    changes = [float(change.text.replace(',', '')) for change in page.find_all('td', class_='data-col3')]
    percent_changes = [float(percent_change.text.replace('%','').replace(',', '')) for percent_change in page.find_all('td', class_='data-col4')]
    volumes = [volume.text for volume in page.find_all('td', class_='data-col5')]

    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    for i in range(0, len(names)):
        cur.execute('INSERT INTO world (name, price, change, percent_change, volume, ts) VALUES (%s, %s, %s, %s, %s, %s)',
                    (names[i], prices[i], changes[i], percent_changes[i], volumes[i], current_time))

        conn.commit()
