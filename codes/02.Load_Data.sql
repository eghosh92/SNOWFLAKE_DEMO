

--- Load sales_fact and article dimensions from stage

USE DATABASE DASH_CORTEX_AGENTS;
USE SCHEMA DATA;
CREATE TABLE IF NOT EXISTS store_dimension (
  -- Unique identifier for each store
  store_id INT PRIMARY KEY,
  -- Name of the store
  store_name STRING,
  -- Physical location of the store
  location STRING
);

COPY INTO "DASH_CORTEX_AGENTS"."DATA"."STORE_DIMENSION"
FROM (
    -- Select store ID, name, and location from source file
    SELECT $1, $2, $3
    FROM '@"DASH_CORTEX_AGENTS"."DATA"."DOCS"'
)
FILES = ('store_dimension.csv')
FILE_FORMAT = (
    TYPE=CSV,
    SKIP_HEADER=1,
    FIELD_DELIMITER=',',
    TRIM_SPACE=TRUE,
    FIELD_OPTIONALLY_ENCLOSED_BY='"',
    REPLACE_INVALID_CHARACTERS=TRUE,
    DATE_FORMAT=AUTO,
    TIME_FORMAT=AUTO,
    TIMESTAMP_FORMAT=AUTO
);


-- Create dimension table for date-related attributes
CREATE TABLE IF NOT EXISTS date_dimension (
  date_id INT PRIMARY KEY,
  date DATE,
  day INT,
  month INT,
  year INT,
  weekday STRING
);


-- Load historical date data from CSV file
COPY INTO "DASH_CORTEX_AGENTS"."DATA"."DATE_DIMENSION"
FROM (
    -- Select all date dimension attributes from source file
    SELECT $1, $2, $3, $4, $5, $6
    FROM '@"DASH_CORTEX_AGENTS"."DATA"."DOCS"'
)
FILES = ('date_dimension.csv')
FILE_FORMAT = (
    TYPE=CSV,
    SKIP_HEADER= 1,
    FIELD_DELIMITER=',',
    TRIM_SPACE=TRUE,
    FIELD_OPTIONALLY_ENCLOSED_BY='"',
    REPLACE_INVALID_CHARACTERS=TRUE,
    DATE_FORMAT=AUTO,
    TIME_FORMAT=AUTO,
    TIMESTAMP_FORMAT=AUTO
);

-- Remove the data already loaded in the db.schema

-- REMOVE @DASH_CORTEX_AGENTS.DATA.DOCS/article_dimension.csv;
-- REMOVE @DASH_CORTEX_AGENTS.DATA.DOCS/sales_fact.csv;
-- REMOVE @DASH_CORTEX_AGENTS.DATA.DOCS/store_dimension.csv;
-- REMOVE @DASH_CORTEX_AGENTS.DATA.DOCS/date_dimension.csv;

LIST @DASH_CORTEX_AGENTS.DATA.DOCS;





