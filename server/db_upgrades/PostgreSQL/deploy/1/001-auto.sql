-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Fri Apr 10 13:47:22 2015
-- 
;
--
-- Table: hardware.
--
CREATE TABLE "hardware" (
  "id" serial NOT NULL,
  "name" character varying(150) NOT NULL,
  "type" character varying(50) NOT NULL,
  "permission_set_id" integer,
  "c_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "m_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "data" json,
  PRIMARY KEY ("id")
);

;
