select plan_table_output
from   table(dbms_xplan.display_cursor(sql_id, sql_child_number));