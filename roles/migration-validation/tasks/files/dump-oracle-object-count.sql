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
    DBMS_OUTPUT.PUT_LINE('OWNER,OBJECT_TYPE,OBJECT_COUNT,STATUS');

    FOR rec IN (
        SELECT owner,
               object_type,
               COUNT(*) AS object_count,
               status
        FROM dba_objects
        WHERE owner = v_owner
        GROUP BY owner, object_type, status
        ORDER BY owner, object_type
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.owner || ',' ||
            rec.object_type || ',' ||
            rec.object_count || ',' ||
            rec.status
        );
    END LOOP;
END;
/
