import requests
import bs4
import psycopg2 
from datetime import datetime


def scrape_crypto(cur, conn):
    target_url = 'https://finance.yahoo.com/cryptocurrencies'
    res = requests.get(target_url)
    page = bs4.BeautifulSoup(res.content, 'html.parser')

    names = [name.text for name in page.find_all('td', attrs={'aria-label':'Name'})]
    prices = [float(price.find('span').text.replace(',','')) for price in page.find_all('td', attrs={'aria-label':'Price (Intraday)'})]
    changes = [float(change.text) for change in page.find_all('td', attrs={'aria-label':'Change'})]
    percent_changes = [float(percent_change.text.replace('%', '').replace(',', '')) for percent_change in page.find_all('td', attrs={'aria-label':'% Change'})]
    market_caps = [market_cap.text for market_cap in page.find_all('td', attrs={'aria-label':'Market Cap'})]
    total_volumes = [total_volume.text for total_volume in page.find_all('td', attrs={'aria-label':'Volume in Currency (Since 0:00 UTC)'})]
    circulate_supplys = [circulate_supply.text for circulate_supply in page.find_all('td', attrs={'aria-label':'Circulating Supply'})]


    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    for i in range(0, len(names)):
        cur.execute('INSERT INTO crypto (name, price, change, percent_change, market_cap, total_volume, circulate_supply, ts) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)',
                    (names[i], prices[i], changes[i], percent_changes[i], market_caps[i], total_volumes[i], circulate_supplys[i], current_time))

        conn.commit()



