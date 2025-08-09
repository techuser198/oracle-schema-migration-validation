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
    DBMS_OUTPUT.PUT_LINE('SYNONYM_NAME,TABLE_NAME');

    FOR rec IN (
        SELECT synonym_name,
               table_name
        FROM all_synonyms
        WHERE owner = v_owner
        ORDER BY synonym_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.synonym_name || ',' ||
            rec.table_name
        );
    END LOOP;
END;
/
