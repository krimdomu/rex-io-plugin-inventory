-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sun May 15 15:19:29 2016
-- 

;
BEGIN TRANSACTION;
--
-- Table: hardware
--
CREATE TABLE hardware (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name varchar(150) NOT NULL,
  type varchar(50) NOT NULL,
  c_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  m_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
--
-- Table: invgroup
--
CREATE TABLE invgroup (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name varchar(150) NOT NULL,
  root_id integer,
  lft integer NOT NULL,
  rgt integer NOT NULL,
  level integer NOT NULL,
  c_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  m_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (root_id) REFERENCES invgroup(root_id) ON UPDATE CASCADE
);
CREATE INDEX invgroup_idx_root_id ON invgroup (root_id);
--
-- Table: property
--
CREATE TABLE property (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
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
