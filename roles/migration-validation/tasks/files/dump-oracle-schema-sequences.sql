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
    DBMS_OUTPUT.PUT_LINE('SEQUENCE_NAME,MIN_VALUE,MAX_VALUE,CACHE_SIZE');

    FOR rec IN (
        SELECT sequence_name,
               min_value,
               max_value,
               cache_size
        FROM all_sequences
        WHERE sequence_owner = v_owner
          AND sequence_name NOT LIKE 'ISEQ$$_%'
        ORDER BY sequence_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.sequence_name || ',' ||
            rec.min_value || ',' ||
            rec.max_value || ',' ||
            rec.cache_size
        );
    END LOOP;
END;
/
