-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Fri Feb 12 20:17:30 2016
-- 

;
BEGIN TRANSACTION;
--
-- Table: hardware
--
CREATE TABLE hardware (
  id integer PRIMARY KEY,
  name varchar(150) NOT NULL,
  type varchar(50) NOT NULL,
  c_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  m_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
--
-- Table: property
--
CREATE TABLE property (
  id integer PRIMARY KEY,
  hardware_id integer NOT NULL,
  name varchar(150) NOT NULL,
  value text,
  c_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  m_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  m_user varchar DEFAULT '',
  FOREIGN KEY (hardware_id) REFERENCES hardware(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX property_idx_hardware_id ON property (hardware_id);
COMMIT;
