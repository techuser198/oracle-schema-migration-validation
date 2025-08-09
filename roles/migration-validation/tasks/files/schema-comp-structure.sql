SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
SET VERIFY OFF
SET ECHO OFF

DEFINE schema_name = '&1';

DECLARE
    v_schema VARCHAR2(128) := UPPER('&schema_name');
BEGIN

    FOR obj_rec IN (
        SELECT TABLE_NAME, 'BASE TABLE' AS obj_type
        FROM ALL_TABLES
        WHERE OWNER = v_schema AND IOT_NAME IS NULL
        UNION
        SELECT VIEW_NAME, 'VIEW' AS obj_type
        FROM ALL_VIEWS
        WHERE OWNER = v_schema
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(v_schema || ',' || obj_rec.TABLE_NAME || ',(' || obj_rec.obj_type || '),' || obj_rec.TABLE_NAME || ',Exists');
    END LOOP;

    FOR col_rec IN (
        SELECT
            atc.OWNER,
            atc.TABLE_NAME,
            atc.COLUMN_NAME,
            atc.COLUMN_ID,
            atc.DATA_TYPE,
            atc.DATA_PRECISION,
            atc.DATA_SCALE,
            atc.CHAR_LENGTH,
            atc.NULLABLE
        FROM ALL_TAB_COLUMNS atc
        JOIN ALL_TABLES t ON atc.OWNER = t.OWNER AND atc.TABLE_NAME = t.TABLE_NAME
        WHERE atc.OWNER = v_schema
        ORDER BY atc.OWNER, atc.TABLE_NAME, atc.COLUMN_ID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            col_rec.OWNER || ',' ||
            col_rec.TABLE_NAME || ',' ||
            'Column' || ',' ||
            col_rec.COLUMN_NAME || ',' ||
            LPAD(col_rec.COLUMN_ID, 3, '0') || ' | ' ||
            col_rec.DATA_TYPE ||
                CASE
                    WHEN col_rec.DATA_TYPE IN ('CHAR', 'VARCHAR2', 'NCHAR', 'NVARCHAR2') THEN '(' || col_rec.CHAR_LENGTH || ')'
                    WHEN col_rec.DATA_TYPE = 'NUMBER' THEN '(' || NVL(col_rec.DATA_PRECISION, 0) || ',' || NVL(col_rec.DATA_SCALE, 0) || ')'
                    ELSE ''
                END || ' | ' ||
            CASE col_rec.NULLABLE WHEN 'Y' THEN 'NULL' ELSE 'NOT NULL' END
        );
    END LOOP;

    FOR cons_rec IN (
        SELECT
            ac.OWNER,
            ac.TABLE_NAME,
            ac.CONSTRAINT_TYPE,
            ac.CONSTRAINT_NAME,
            LISTAGG(acc.COLUMN_NAME, ',') WITHIN GROUP (ORDER BY acc.POSITION) AS cols
        FROM ALL_CONSTRAINTS ac
        JOIN ALL_CONS_COLUMNS acc
          ON ac.OWNER = acc.OWNER
         AND ac.TABLE_NAME = acc.TABLE_NAME
         AND ac.CONSTRAINT_NAME = acc.CONSTRAINT_NAME
        WHERE ac.OWNER = v_schema
          AND ac.CONSTRAINT_TYPE IN ('P', 'U', 'R')
          AND ac.CONSTRAINT_NAME NOT LIKE 'SYS_%'
          AND ac.TABLE_NAME NOT LIKE 'BIN$%'
        GROUP BY ac.OWNER, ac.TABLE_NAME, ac.CONSTRAINT_TYPE, ac.CONSTRAINT_NAME
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            cons_rec.OWNER || ',' ||
            cons_rec.TABLE_NAME || ',' ||
            CASE cons_rec.CONSTRAINT_TYPE
                WHEN 'P' THEN 'PKey'
                WHEN 'U' THEN 'UKey'
                WHEN 'R' THEN 'FKey'
            END || ',' ||
            cons_rec.CONSTRAINT_NAME || ',' ||
            cons_rec.cols
        );
    END LOOP;

    FOR idx_rec IN (
        SELECT
            ai.TABLE_OWNER,
            ai.TABLE_NAME,
            ai.INDEX_NAME,
            LISTAGG(aic.COLUMN_NAME, ',')
                WITHIN GROUP (ORDER BY aic.COLUMN_POSITION) AS cols
        FROM ALL_INDEXES ai
        JOIN ALL_IND_COLUMNS aic
          ON ai.OWNER = aic.INDEX_OWNER
         AND ai.TABLE_NAME = aic.TABLE_NAME
         AND ai.INDEX_NAME = aic.INDEX_NAME
        WHERE ai.TABLE_OWNER = v_schema
          AND ai.INDEX_NAME NOT LIKE 'SYS_%'
        GROUP BY ai.TABLE_OWNER, ai.TABLE_NAME, ai.INDEX_NAME
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            idx_rec.TABLE_OWNER || ',' ||
            idx_rec.TABLE_NAME || ',' ||
            'Index' || ',' ||
            idx_rec.INDEX_NAME || ',' ||
            idx_rec.cols
        );
    END LOOP;
END;
/
