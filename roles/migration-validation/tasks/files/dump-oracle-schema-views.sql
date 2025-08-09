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
    DBMS_OUTPUT.PUT_LINE('VIEW_NAME,TEXT');

    FOR rec IN (
        SELECT view_name,
               text
        FROM all_views
        WHERE owner = v_owner
        ORDER BY view_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.view_name || ',' ||
            REPLACE(REPLACE(rec.text, CHR(10), ' '), CHR(13), ' ')
        );
    END LOOP;
END;
/
