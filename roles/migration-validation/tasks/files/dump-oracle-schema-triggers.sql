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
    DBMS_OUTPUT.PUT_LINE('TRIGGER_NAME,TABLE_NAME,TRIGGER_TYPE,TRIGGERING_EVENT,TRIGGER_BODY');

    FOR rec IN (
        SELECT trigger_name,
               table_name,
               trigger_type,
               triggering_event,
               trigger_body
        FROM all_triggers
        WHERE owner = v_owner
        ORDER BY trigger_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.trigger_name || ',' ||
            rec.table_name || ',' ||
            rec.trigger_type || ',' ||
            rec.triggering_event || ',' ||
            REPLACE(REPLACE(rec.trigger_body, CHR(10), ' '), CHR(13), ' ')
        );
    END LOOP;
END;
/
