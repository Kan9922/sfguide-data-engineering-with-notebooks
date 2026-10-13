/*-----------------------------------------------------------------------------
Hands-On Lab: Intro to Data Engineering with Notebooks
Script:       setup.sql
Author:       Shivam Gupta
Last Updated: 6/16/2026
-----------------------------------------------------------------------------*/


-- ----------------------------------------------------------------------------
-- Create the account level objects
-- ----------------------------------------------------------------------------
SELECT CURRENT_USER();
SET MY_USER = CURRENT_USER();
USE ROLE ACCOUNTADMIN;

-- Roles
SELECT CURRENT_ROLE();
CREATE OR REPLACE ROLE DEMO_ROLE;
GRANT ROLE DEMO_ROLE TO ROLE SYSADMIN;
GRANT ROLE DEMO_ROLE TO USER IDENTIFIER($MY_USER);

GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE DEMO_ROLE;
GRANT EXECUTE TASK ON ACCOUNT TO ROLE DEMO_ROLE;
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE DEMO_ROLE;
GRANT MONITOR EXECUTION ON ACCOUNT TO ROLE DEMO_ROLE;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE DEMO_ROLE;
--GRANT USAGE ON INTEGRATION GITHUB_API_INTEGRATION TO ROLE DEMO_ROLE;

-- Databases
SELECT CURRENT_DATABASE();
CREATE OR REPLACE DATABASE DEMO_DB;
GRANT OWNERSHIP ON DATABASE DEMO_DB TO ROLE DEMO_ROLE;

-- Warehouses
SELECT CURRENT_WAREHOUSE();
CREATE OR REPLACE WAREHOUSE DEMO_WH WAREHOUSE_SIZE = XSMALL, AUTO_SUSPEND = 300, AUTO_RESUME= TRUE;
GRANT OWNERSHIP ON WAREHOUSE DEMO_WH TO ROLE DEMO_ROLE;


-- ----------------------------------------------------------------------------
-- Create the database level objects
-- ----------------------------------------------------------------------------
USE ROLE DEMO_ROLE;
USE WAREHOUSE DEMO_WH;
USE DATABASE DEMO_DB;

-- Schemas
SELECT CURRENT_SCHEMA();
CREATE OR REPLACE SCHEMA INTEGRATIONS;
CREATE OR REPLACE SCHEMA DEV_SCHEMA;
CREATE OR REPLACE SCHEMA PROD_SCHEMA;

USE SCHEMA INTEGRATIONS;

-- External Frostbyte objects
CREATE OR REPLACE STAGE FROSTBYTE_RAW_STAGE
    URL = 's3://sfquickstarts/data-engineering-with-snowpark-python/'
;


-- ----------------------------------------------------------------------------
-- Create the event table
-- ----------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;

CREATE EVENT TABLE DEMO_DB.INTEGRATIONS.DEMO_EVENTS;
GRANT SELECT ON EVENT TABLE DEMO_DB.INTEGRATIONS.DEMO_EVENTS TO ROLE DEMO_ROLE;
GRANT INSERT ON EVENT TABLE DEMO_DB.INTEGRATIONS.DEMO_EVENTS TO ROLE DEMO_ROLE;

ALTER ACCOUNT SET EVENT_TABLE = DEMO_DB.INTEGRATIONS.DEMO_EVENTS;
ALTER DATABASE DEMO_DB SET LOG_LEVEL = INFO;

-- 1. Drop the existing Git stage reference object
DROP GIT REPOSITORY sfguide_data_engineering_with_notebooks;

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE API INTEGRATION GITHUB_API_INTEGRATION
    API_PROVIDER = GIT_HTTPS_API
    API_ALLOWED_PREFIXES = ('https://github.com/')
    ALLOWED_AUTHENTICATION_SECRETS = ALL
    ENABLED = TRUE;

