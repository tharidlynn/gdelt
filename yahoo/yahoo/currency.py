import os
import requests
import bs4
import psycopg2 

from datetime import datetime

def scrape_currency(cur, conn):
    target_url = 'https://finance.yahoo.com/currencies'
    res = requests.get(target_url)
    page = bs4.BeautifulSoup(res.content, 'html.parser')

    names = []
    prices = []
    changes = []
    percent_changes = []

    for i in range(43, 400, 14):
        for name in page.find_all('td', attrs={'data-reactid':i}):
            names.append(name.text)
        for price in page.find_all('td', attrs={'data-reactid':i+1}):
            prices.append(float(price.text.replace(',', '')))
        for change in page.find_all('td', attrs={'data-reactid':i+2}):
            changes.append(float(change.text))
        for percent_change in page.find_all('td', attrs={'data-reactid':i+4}):
            percent_changes.append(float(percent_change.text.replace('%', '').replace(',', '')))

    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    for i in range(0, len(names)):
        cur.execute('INSERT INTO currency (name, price, change, percent_change, ts) VALUES (%s, %s, %s, %s, %s)',
                    (names[i], prices[i], changes[i], percent_changes[i], current_time))

        conn.commit()
