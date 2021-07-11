select col.column_id, 
       col.owner as schema_name,
       col.table_name, 
       col.column_name, 
       col.data_type, 
       col.data_length, 
       col.data_precision, 
       col.data_scale, 
       col.nullable
from sys.all_tab_columns col
inner join sys.all_tables t on col.owner = t.owner 
                              and col.table_name = t.table_name
where col.table_name = 'PORTFOLIO_DAILY_POSITION'
AND COL.OWNER = 'METROBANK'