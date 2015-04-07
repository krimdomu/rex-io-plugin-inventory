-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Mon Apr  6 22:49:45 2015
-- 
;
--
-- Table: hardware.
--
CREATE TABLE "hardware" (
  "id" serial NOT NULL,
  "name" character varying(150) NOT NULL,
  "permission_set_id" integer,
  "c_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "m_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "data" json,
  PRIMARY KEY ("id")
);

;
