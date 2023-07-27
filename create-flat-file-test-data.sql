DROP TABLE test_data;

-- Create a table to hold the test data
CREATE TABLE test_data (
  column1 VARCHAR2(10),
  column2 VARCHAR2(8),
  column3 VARCHAR2(6),
  column4 VARCHAR2(4)
);

-- Insert 10 rows of test data
INSERT INTO test_data (column1, column2, column3, column4)
SELECT
  LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 100000)), 10, '0') AS column1,
  LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 10000)), 8, '0') AS column2,
  LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 1000)), 6, '0') AS column3,
  LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 100)), 4, '0') AS column4
FROM dual
CONNECT BY LEVEL <= 100000;

COMMIT;

set colsep ","
set linesize 9999
set trimspool on
set heading off
set pagesize 0
set wrap off
set feedback off
set newpage 0
set arraysize 5000
spool C:\Users\38188\Projects\doccerz\test_data.csv
select column1 || column2 || column3 || column4 from test_data;
spool off
