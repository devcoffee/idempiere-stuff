CREATE OR REPLACE FUNCTION qss_get_tables_from_window (p_ad_window_id IN NUMERIC)
   RETURNS VARCHAR
AS
$BODY$
DECLARE
   v_tables   VARCHAR (4000);
   r RECORD;
   j RECORD;
BEGIN
   v_tables := '';
   FOR r IN SELECT   ad_tab_id,
                      RPAD ('+', (tablevel::integer), '+') || ' [' || tablename || '](https://schemaspy.brerp.com.br/adempiere/tables/' || lower(tablename) || '.html) '  tablename
                 FROM ad_tab b, ad_table t
                WHERE b.ad_table_id = t.ad_table_id
                  AND b.ad_window_id = p_ad_window_id AND b.isactive='Y'
             ORDER BY seqno LOOP
      v_tables := v_tables || ' ' || r.tablename || '<br/>';
      FOR j IN (SELECT COALESCE (p.classname, p.procedurename) cmd
                  FROM ad_field f, ad_column c, ad_process p
                 WHERE f.ad_tab_id = r.ad_tab_id
                   AND f.ad_column_id = c.ad_column_id
                   AND c.ad_reference_id = 28
                   AND c.ad_process_id = p.ad_process_id
                UNION
                SELECT COALESCE (p.classname, p.procedurename) cmd
                  FROM ad_toolbarbutton f, ad_process p
                 WHERE f.ad_tab_id = r.ad_tab_id
                   AND f.ad_process_id = p.ad_process_id
                ORDER BY 1)
      LOOP
         IF j.cmd IS NOT NULL
         THEN
            v_tables := v_tables || ' [' || coalesce(j.cmd,'' )|| '](https://javadoc.brerp.com.br/API/' || replace(coalesce(j.cmd,''),'.','/') || '.html) <br/>';
         END IF;
      END LOOP;
   END LOOP;
   RETURN SUBSTR (v_tables, 2);
END;
$BODY$
LANGUAGE 'plpgsql'
