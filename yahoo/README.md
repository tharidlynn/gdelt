# Scraping Yahoo finance

<img src="../img/yahoo-diagram.png" />

A python script which scrapes the [yahoo finance](https://finance.yahoo.com) and saves to PostgreSQL every 15 seconds.

<img src="../img/yahoo-screenshot.png" alt="yahoo-screenshot" title="yahoo-screenshot" style="max-width:100%;" />


The following data will be scraped:
* world-indices
* commodities
* currencies
* cryptocurrencies

<img src="../img/yahoo-results.gif" alt="yahoo-results" title="yahoo-results" style="max-width:100%;" />

## Getting started without Docker
1. `source .env`
2. `python create_db.py`
3. `python main.py`

## Getting started with Dockerfile
_Note: the docker wraps `main.py` only._

1. `source .env` 
2. `python create_db.py`
3. `docker build . -t yahoo`
4. `docker run --name yahoo --rm -it -d -e PGHOST=$PGHOST -e PGDATABASE=$PGDATABASE -e PGUSERNAME=$PGUSERNAME -e PGPASSWORD=$PGPASSWORD yahoo`

## Pushing to ECR
1. `docker build . -t yahoo`
2. `docker tag yahoo 111111111111.dkr.ecr.ap-southeast-1.amazonaws.com/yahoo`
3. `eval $(aws ecr get-login  --no-include-email)`
4. `aws ecr create-repository --repository-name yahoo`
5. `docker push 111111111111.dkr.ecr.ap-southeast-1.amazonaws.com/yahoo`

