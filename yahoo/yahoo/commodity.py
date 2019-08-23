import requests
import bs4
import psycopg2 
from datetime import datetime

def scrape_commodity(cur, conn):
    target_url = 'https://finance.yahoo.com/commodities'
    res = requests.get(target_url)
    page = bs4.BeautifulSoup(res.content, 'html.parser')

    names = [name.text for name in page.find_all('td', class_='data-col1')]
    prices = [float(price.text.replace(',', '')) if price.text != '-' else None for price in page.find_all('td', class_='data-col2')]
    market_times = [time.text for time in page.find_all('td', class_='data-col3')]
    changes = [float(change.text) if change.text != '-' else None for change in page.find_all('td', class_='data-col4')]
    percent_changes = [float(percent_change.text.replace('%', '').replace(',', '')) if percent_change.text != '-' else None for percent_change in page.find_all('td', class_='data-col5')]
    volumes = [int(volume.text.replace(',', '')) if volume.text != '-' else None for volume in page.find_all('td', class_='data-col6')]
    open_interests = [int(interest.text.replace(',', '')) if interest.text != '-' else None for interest in page.find_all('td', class_='data-col7')]

    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    for i in range(0, len(names)):
        cur.execute('INSERT INTO commodity (name, price, market_time, change, percent_change, volume, open_interest, ts) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)',
                    (names[i], prices[i], market_times[i], changes[i], percent_changes[i], volumes[i], open_interests[i], current_time))

        conn.commit()
