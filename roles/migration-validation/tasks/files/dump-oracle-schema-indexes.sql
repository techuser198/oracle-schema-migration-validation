WHENEVER SQLERROR EXIT SQL.SQLCODE
SET MARKUP CSV ON;
SET SERVEROUTPUT ON;
SET LINESIZE 1000;
SET TRIMSPOOL ON;
SET VERIFY OFF;
SET FEEDBACK OFF;

DECLARE
    v_owner VARCHAR2(100) := '&1';
BEGIN
    DBMS_OUTPUT.PUT_LINE('INDEX_NAME,TABLE_NAME,INDEX_TYPE,TABLESPACE_NAME');

    FOR rec IN (
        SELECT index_name,
               table_name,
               index_type,
               tablespace_name
        FROM all_indexes
        WHERE owner = v_owner
          AND index_name NOT LIKE 'SYS_%'
        ORDER BY index_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.index_name || ',' ||
            rec.table_name || ',' ||
            rec.index_type || ',' ||
            rec.tablespace_name
        );
    END LOOP;
END;
/
