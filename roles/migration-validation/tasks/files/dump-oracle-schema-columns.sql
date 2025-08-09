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
    DBMS_OUTPUT.PUT_LINE('TABLE_NAME,COLUMN_NAME,DATA_TYPE,DATA_LENGTH,DATA_PRECISION,DATA_SCALE,NULLABLE');

    FOR rec IN (
        SELECT col.table_name,
               col.column_name,
               col.data_type,
               col.data_length,
               col.data_precision,
               col.data_scale,
               col.nullable
        FROM all_tab_columns col
        JOIN all_tables t ON col.owner = t.owner AND col.table_name = t.table_name
        WHERE col.owner = v_owner
        ORDER BY col.table_name, col.column_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.table_name || ',' ||
            rec.column_name || ',' ||
            rec.data_type || ',' ||
            rec.data_length || ',' ||
            NVL(TO_CHAR(rec.data_precision), '') || ',' ||
            NVL(TO_CHAR(rec.data_scale), '') || ',' ||
            rec.nullable
        );
    END LOOP;
END;
/
