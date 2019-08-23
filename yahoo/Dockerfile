FROM python:3.7-slim

COPY create_db.py main.py /app/
COPY yahoo /app/yahoo

WORKDIR /app

RUN pip install psycopg2-binary
RUN pip install beautifulsoup4
RUN pip install requests

ENV PGHOST=host.docker.internal
ENV PGDATABASE=yahoo_finance
ENV PGUSERNAME=john
ENV PGPASSWORD=

ENTRYPOINT [ "python" ]
CMD ["main.py"]
