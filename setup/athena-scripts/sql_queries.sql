
-- Count total events, S3 CSV
SELECT COUNT(*)
FROM gdelt.event;

-- Count total events, S3 Parquet
SELECT COUNT(*)
FROM gdelt.eventparquet;

-- Show 10 events
SELECT *
FROM gdelt.event LIMIT 10;

-- Show 10 event codes
SELECT *
FROM gdelt.eventcode LIMIT 10;

-- Show 10 types
SELECT *
FROM gdelt.type LIMIT 10;

-- Show 10 groups
SELECT *
FROM gdelt.group LIMIT 10;

-- Show 10 countries
SELECT *
FROM gdelt.country LIMIT 10;

-- Find the number of events per year
SELECT year,
       COUNT(globaleventid) AS nb_events
FROM gdelt.event
GROUP BY year
ORDER BY year ASC;

-- Find the top 10 countries with the most events
SELECT day,
       COUNT(globaleventid) AS nb_events
FROM gdelt.event
GROUP BY day
ORDER BY nb_events DESC limit 10;

-- Find the top 10 days with the most events
SELECT day,
       COUNT(globaleventid) AS nb_events
FROM gdelt.event
GROUP BY day
ORDER BY nb_events DESC limit 10;

-- Show top 10 event categories
SELECT eventcode,
       gdelt.eventcode.description,
       nb_events
FROM (SELECT gdelt.events.eventcode,
             COUNT(gdelt.events.globaleventid) AS nb_events
      FROM gdelt.event
      GROUP BY gdelt.event.eventcode
      ORDER BY nb_events DESC LIMIT 10)
  JOIN gdelt.eventcode ON eventcode = gdelt.eventcode.code
ORDER BY nb_events DESC;

-- Same one, with S3 Parquet
SELECT eventcode,
       gdelt.eventcode.description,
       nb_events
FROM (SELECT gdelt.eventparquet.eventcode,
             COUNT(gdelt.eventparquet.globaleventid) AS nb_events
      FROM gdelt.eventparquet
      GROUP BY gdelt.eventparquet.eventcode
      ORDER BY nb_events DESC LIMIT 10)
  JOIN gdelt.eventcode ON eventcode = gdelt.eventcode.code
ORDER BY nb_events DESC;

-- Count Obama events per year
SELECT year,
       COUNT(globaleventid) AS nb_events
FROM gdelt.event
WHERE actor1name='BARACK OBAMA'
GROUP BY year
ORDER BY year ASC;

-- Same one, with S3 Parquet
SELECT year,
       COUNT(globaleventid) AS nb_events
FROM gdelt.eventparquet
WHERE actor1name='BARACK OBAMA'
GROUP BY year
ORDER BY year ASC;

-- Count Obama/Putin events per category
SELECT eventcode,
       gdelt.eventcode.description,
       nb_events
FROM (SELECT gdelt.event.eventcode,
             COUNT(gdelt.event.globaleventid) AS nb_events
      FROM gdelt.event
      WHERE actor1name='BARACK OBAMA'and actor2name='VLADIMIR PUTIN'
      GROUP BY gdelt.events.eventcode
      ORDER BY nb_events DESC)
  JOIN gdelt.eventcode ON eventcode = gdelt.eventcode.code
ORDER BY nb_events DESC;

-- Count Obama/Putin and Putin/Obama events per category
WITH tmp as (SELECT gdelt.event.eventcode,
         COUNT(gdelt.event.globaleventid) AS nb_events
    FROM gdelt.event
    WHERE ((actor1name LIKE '%OBAMA' and actor2name LIKE '%PUTIN')
            OR (actor2name LIKE '%OBAMA' and actor1name LIKE '%PUTIN'))
    GROUP BY  gdelt.event.eventcode
    ORDER BY  nb_events DESC)
SELECT eventcode,
         gdelt.eventcode.description,
         nb_events
FROM tmp
JOIN gdelt.eventcode
    ON eventcode = gdelt.eventcodes.code
ORDER BY  nb_events DESC;

-- Same one, with S3 Parquet
WITH tmp as (SELECT gdelt.eventparquet.eventcode,
         COUNT(gdelt.eventparquet.globaleventid) AS nb_events
    FROM gdelt.eventparquet
    WHERE ((actor1name LIKE '%OBAMA' and actor2name LIKE '%PUTIN')
            OR (actor2name LIKE '%OBAMA' and actor1name LIKE '%PUTIN'))
    GROUP BY  gdelt.eventparquet.eventcode
    ORDER BY  nb_events DESC)
SELECT eventcode,
         gdelt.eventcode.description,
         nb_events
FROM tmp
JOIN gdelt.eventcode
    ON eventcode = gdelt.eventcode.code
ORDER BY  nb_events DESC;

-- HIVE : same one
USE gdelt;
WITH tmp as (SELECT eventparquet.eventcode,
         COUNT(eventparquet.globaleventid) AS nb_events
    FROM eventparquet
    WHERE ((actor1name LIKE '%OBAMA' and actor2name LIKE '%PUTIN')
            OR (actor2name LIKE '%OBAMA' and actor1name LIKE '%PUTIN'))
    GROUP BY  eventparquet.eventcode
    ORDER BY  nb_events DESC)
SELECT eventcode,
         eventcode.description,
         nb_events
FROM tmp
JOIN eventcode
    ON eventcode = eventcode.code
ORDER BY  nb_events DESC;

-- HIVE - Same one on HDFS instead of S3
USE gdelt;
WITH tmp as (SELECT eventparquetlocal.eventcode,
         COUNT(eventparquetlocal.globaleventid) AS nb_events
    FROM eventparquetlocal
    WHERE ((actor1name LIKE '%OBAMA' and actor2name LIKE '%PUTIN')
            OR (actor2name LIKE '%OBAMA' and actor1name LIKE '%PUTIN'))
    GROUP BY  eventparquetlocal.eventcode
    ORDER BY  nb_events DESC)
SELECT eventcode,
         eventcode.description,
         nb_events
FROM tmp
JOIN eventcode
    ON eventcode = eventcode.code
ORDER BY  nb_events DESC;


