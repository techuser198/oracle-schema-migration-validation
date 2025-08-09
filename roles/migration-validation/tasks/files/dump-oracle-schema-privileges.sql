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
    DBMS_OUTPUT.PUT_LINE('TABLE_NAME,GRANTEE,PRIVILEGE,TYPE');

    FOR rec IN (
        SELECT table_name,
               grantee,
               privilege,
               type
        FROM dba_tab_privs
        WHERE owner = v_owner
          AND table_name NOT LIKE 'BIN$%'
        ORDER BY table_name, grantee, privilege
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.table_name || ',' ||
            rec.grantee || ',' ||
            rec.privilege || ',' ||
            rec.type
        );
    END LOOP;
END;
/
