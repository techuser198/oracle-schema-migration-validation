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
    DBMS_OUTPUT.PUT_LINE('TABLE_NAME,CONSTRAINT_NAME,CONSTRAINT_TYPE,STATUS,VALIDATED,SEARCH_CONDITION,SEARCH_CONDITION_VC,INDEX_NAME');

    FOR rec IN (
        SELECT table_name,
               constraint_name,
               constraint_type,
               status,
               validated,
               search_condition,
               search_condition_vc,
               index_name
        FROM all_constraints
        WHERE owner = v_owner
          AND constraint_name NOT LIKE 'SYS_%'
          AND table_name NOT LIKE 'BIN$%'
          AND constraint_name NOT LIKE 'BIN$%'
        ORDER BY table_name, search_condition_vc, constraint_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.table_name || ',' ||
            rec.constraint_name || ',' ||
            rec.constraint_type || ',' ||
            rec.status || ',' ||
            rec.validated || ',' ||
            REPLACE(NVL(rec.search_condition, ''), ',', ' ') || ',' ||
            REPLACE(NVL(rec.search_condition_vc, ''), ',', ' ') || ',' ||
            NVL(rec.index_name, '')
        );
    END LOOP;
END;
/
