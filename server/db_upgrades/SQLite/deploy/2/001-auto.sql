-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Tue May 17 16:22:26 2016
-- 

;
BEGIN TRANSACTION;
--
-- Table: invgroup
--
CREATE TABLE invgroup (
  id serial NOT NULL,
  name varchar(150) NOT NULL,
  root_id integer,
  lft integer NOT NULL,
  rgt integer NOT NULL,
  level integer NOT NULL,
  c_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  m_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (root_id) REFERENCES invgroup(root_id) ON UPDATE CASCADE
);
CREATE INDEX invgroup_idx_root_id ON invgroup (root_id);
--
-- Table: hardware
--
CREATE TABLE hardware (
  id serial NOT NULL,
  name varchar(150) NOT NULL,
  type varchar(50) NOT NULL,
  group_id integer NOT NULL DEFAULT 1,
  c_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  m_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (group_id) REFERENCES invgroup(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX hardware_idx_group_id ON hardware (group_id);
--
-- Table: property
--
CREATE TABLE property (
  id serial NOT NULL,
  hardware_id integer NOT NULL,
  name varchar(150) NOT NULL,
  value text,
  c_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  m_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  m_user varchar DEFAULT '',
  PRIMARY KEY (id),
  FOREIGN KEY (hardware_id) REFERENCES hardware(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX property_idx_hardware_id ON property (hardware_id);
COMMIT;
