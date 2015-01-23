CREATE TABLE IF NOT EXISTS agg_status (                                         
  timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,                                             
  bikes integer NOT NULL,                                                                            
  spaces integer NOT NULL,                                                                            
  unbalanced integer NOT NULL                                                                         
);

CREATE TABLE IF NOT EXISTS station_status (
  tfl_id integer NOT NULL,
  bikes integer NOT NULL,
  spaces integer NOT NULL,
  timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (tfl_id,timestamp),
  KEY timestamp
);