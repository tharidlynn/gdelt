CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS event (
	globaleventid INTEGER,
	day INTEGER,
	monthyear INTEGER,
	year INTEGER,
	fractiondate FLOAT,
	actor1code TEXT,
	actor1name TEXT,
	actor1countrycode TEXT,
	actor1knowngroupcode TEXT,
	actor1ethniccode TEXT,
	actor1religion1code TEXT,
	actor1religion2code TEXT,
	actor1type1code TEXT,
	actor1type2code TEXT,
	actor1type3code TEXT,
	actor2code TEXT,
	actor2name TEXT,
	actor2countrycode TEXT,
	actor2knowngroupcode TEXT,
	actor2ethniccode TEXT,
	actor2religion1code TEXT,
	actor2religion2code TEXT,
	actor2type1code TEXT,
	actor2type2code TEXT,
	actor2type3code TEXT,
	isrootevent INTEGER,
	eventcode TEXT,
	eventbasecode TEXT,
	eventrootcode TEXT,
	quadclass INTEGER,
	goldsteinscale FLOAT,
	nummentions INTEGER,
	numsources INTEGER,
	numarticles INTEGER,
	avgtone FLOAT,
	actor1geo_type INTEGER,
	actor1geo_fullname TEXT,
	actor1geo_countrycode TEXT,
	actor1geo_adm1code TEXT,
	actor1geo_lat FLOAT,
	actor1geo_long FLOAT,
	actor1geo_featureid TEXT,
	actor2geo_type INTEGER,
	actor2geo_fullname TEXT,
	actor2geo_countrycode TEXT,
	actor2geo_adm1code TEXT,
	actor2geo_lat FLOAT,
	actor2geo_long FLOAT,
	actor2geo_featureid TEXT,
	actiongeo_type INTEGER,
	actiongeo_fullname TEXT,
	actiongeo_countrycode TEXT,
	actiongeo_adm1code TEXT,
	actiongeo_lat FLOAT,
	actiongeo_long FLOAT,
	actiongeo_featureid TEXT,
	dateadded INTEGER,
	sourceurl TEXT,
    PRIMARY KEY(globaleventid))
DISTKEY(globaleventid)
SORTKEY(day);

CREATE  TABLE IF NOT EXISTS eventcode (
	code TEXT,
	description TEXT)
DISTSTYLE ALL;

CREATE  TABLE IF NOT EXISTS type (
	type TEXT,
	description TEXT)
DISTSTYLE ALL;

CREATE  TABLE IF NOT EXISTS "group" (
	"group" TEXT,
	description TEXT)
DISTSTYLE ALL;

CREATE  TABLE IF NOT EXISTS country (
	code TEXT,
	country TEXT)
DISTSTYLE ALL;

CREATE TABLE IF NOT EXISTS staging.event (LIKE event);