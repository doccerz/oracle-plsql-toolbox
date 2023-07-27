-- USAGE: EXECUTE P_STORE_FILE ('DUMPFILES', 'test.csv', 'SELECT ''1 2 3'' AS A, 2 AS B FROM DUAL', ','); 
CREATE OR REPLACE PROCEDURE P_STORE_FILE(
  p_file_dir    VARCHAR2, -- mandatory (Oracle directory name)
  p_file_name VARCHAR2, -- mandatory
  P_SQL_QUERY   VARCHAR2, -- Multiple column SQL SELECT statement that needs to be executed and processed
  p_delimiter CHAR    -- column delimiter
)
AS
  l_cursor_handle  INTEGER;
  l_dummy     NUMBER;
  l_col_cnt     INTEGER;
  l_rec_tab     DBMS_SQL.DESC_TAB;
  l_current_col    NUMBER(16);
  l_current_line   VARCHAR2(32000);
  l_column_value   VARCHAR2(300);
  
  l_file_handle    UTL_FILE.FILE_TYPE;
  l_print_text     VARCHAR2(100);
  l_record_count   NUMBER(16) := 0;


BEGIN


   /* Open file for append*/
   l_file_handle := UTL_FILE.FOPEN(p_file_dir, p_file_name, 'w', 32000); 
   
   l_cursor_handle := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(l_cursor_handle, p_sql_query, DBMS_SQL.native);
   l_dummy := DBMS_SQL.EXECUTE(l_cursor_handle);


   /* Output column names and define them for latter retrieval of data */
   DBMS_SQL.DESCRIBE_COLUMNS(l_cursor_handle, l_col_cnt, l_rec_tab); -- get column names


   /* Append to file column headers */
   l_current_col := l_rec_tab.FIRST;
   IF (l_current_col IS NOT NULL) THEN
      LOOP
         DBMS_SQL.DEFINE_COLUMN(l_cursor_handle, l_current_col, l_column_value, 300);
         L_PRINT_TEXT := '"' || L_REC_TAB(L_CURRENT_COL).COL_NAME || '"'|| P_DELIMITER;
  
         --UTL_FILE.PUT (l_file_handle, l_print_text);
         L_CURRENT_COL := L_REC_TAB.NEXT(L_CURRENT_COL);
         
         IF L_CURRENT_COL IS NULL THEN          
          L_PRINT_TEXT := SUBSTR(L_PRINT_TEXT, 1, INSTR(L_PRINT_TEXT, P_DELIMITER, -1, 1)-1 );
          --DBMS_OUTPUT.PUT_LINE('L_PRINT_TEXT='||L_PRINT_TEXT);
         END IF;
         UTL_FILE.PUT (l_file_handle, l_print_text);
         
         EXIT WHEN (l_current_col IS NULL);
      END LOOP;
   END IF;
   UTL_FILE.PUT_LINE (l_file_handle,' ');


   /* Append data for each row */
   LOOP
      EXIT WHEN DBMS_SQL.FETCH_ROWS(l_cursor_handle) = 0; -- no more rows to be fetched


      l_current_line := '';
      /* Append data for each column */
      FOR l_current_col IN 1..l_col_cnt LOOP
        DBMS_SQL.COLUMN_VALUE (l_cursor_handle, l_current_col, l_column_value);
        l_print_text := l_column_value || p_delimiter;
        
        l_current_line := l_current_line || '"' || l_column_value || '"' || p_delimiter;
      END LOOP;
      L_RECORD_COUNT := L_RECORD_COUNT + 1;
      L_CURRENT_LINE := SUBSTR(L_CURRENT_LINE, 1, INSTR(L_CURRENT_LINE, P_DELIMITER, -1, 1)-1 );
      --DBMS_OUTPUT.PUT_LINE('l_current_line='||l_current_line);
      UTL_FILE.PUT_LINE (l_file_handle, l_current_line);
   END LOOP;


   UTL_FILE.FCLOSE (l_file_handle);
   DBMS_SQL.CLOSE_CURSOR(l_cursor_handle);


EXCEPTION
   WHEN OTHERS THEN


   -- Release resources
   IF DBMS_SQL.IS_OPEN(l_cursor_handle) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor_handle);
   END IF;


   IF UTL_FILE.IS_OPEN (l_file_handle) THEN
      UTL_FILE.FCLOSE (l_file_handle);
   END IF;


   RAISE_APPLICATION_ERROR(-20000, SQLCODE||' Unable to store files in server location: '||SQLERRM);
   DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
END;