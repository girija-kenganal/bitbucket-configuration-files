CREATE USER router PASSWORD '123next!';
CREATE USER rms PASSWORD '123next!';
CREATE DATABASE router OWNER router ENCODING 'UTF-8';
CREATE DATABASE rms OWNER rms  ENCODING 'UTF-8';
\connect router;
SET ROLE router;
CREATE SCHEMA router AUTHORIZATION router;
\connect rms;
SET ROLE rms;
CREATE SCHEMA rms AUTHORIZATION rms;
\q