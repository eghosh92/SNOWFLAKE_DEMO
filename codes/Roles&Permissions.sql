use role accountadmin;

-- Create admin role for Snowflake Intelligence
create role if not exists snowflake_intelligence_admin;

-- Grant integration creation privileges
grant create integration on account to role snowflake_intelligence_admin;

-- Grant database creation privileges
grant create database on account to role snowflake_intelligence_admin;

-- Grant warehouse usage privileges
grant usage on warehouse compute_wh to role snowflake_intelligence_admin;
set current_user = (SELECT CURRENT_USER());   
-- Grant admin role to current user
grant role snowflake_intelligence_admin to user IDENTIFIER($current_user);
-- Set default role for current user
alter user set default_role = snowflake_intelligence_admin;

-- Switch to admin role
use role snowflake_intelligence_admin;

-- Create and configure Snowflake Intelligence database
create database if not exists snowflake_intelligence;
GRANT ALL ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE snowflake_intelligence_admin;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE snowflake_intelligence_admin;
create schema if not exists snowflake_intelligence.agents;

-- Create Dash Cortex Agents database and schema
create database if not exists dash_cortex_agents;
create schema if not exists dash_cortex_agents.data;

-- Set working context
use database dash_cortex_agents;
use schema data;

CREATE SECRET if not EXISTS dash_cortex_agents.public.secret_sf_git
    TYPE = PASSWORD
    USERNAME = 'eghosh92'
    PASSWORD = 'XXX';

-- Grant usage permission on the secret
GRANT USAGE ON SECRET dash_cortex_agents.public.secret_sf_git TO ROLE snowflake_intelligence_admin;

-- Create API integration for GitHub access
CREATE OR REPLACE API INTEGRATION my_git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/')
  ALLOWED_AUTHENTICATION_SECRETS = (dash_cortex_agents.public.secret_sf_git)
  ENABLED = TRUE;

-- Create Git repository connection
CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_DEMO 
	ORIGIN = 'https://github.com/eghosh92/SNOWFLAKE_DEMO.git' 
	API_INTEGRATION = 'MY_GIT_API_INTEGRATION' 
	GIT_CREDENTIALS = 'dash_cortex_agents.public.secret_sf_git';

-- Describe the API integration details
DESC INTEGRATION my_git_api_integration;

create or replace stage docs encryption = (type = 'snowflake_sse') directory = ( enable = true );
copy files
    into @docs/
    from @dash_cortex_agents.data.SNOWFLAKE_DEMO/branches/main/docs/;