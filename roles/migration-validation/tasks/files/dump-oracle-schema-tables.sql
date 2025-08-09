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
    DBMS_OUTPUT.PUT_LINE('TABLE_NAME,TABLESPACE_NAME');

    FOR rec IN (
        SELECT table_name,
               tablespace_name
        FROM all_tables
        WHERE owner = v_owner
          AND iot_name IS NULL
        ORDER BY table_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.table_name || ',' ||
            rec.tablespace_name
        );
    END LOOP;
END;
/
