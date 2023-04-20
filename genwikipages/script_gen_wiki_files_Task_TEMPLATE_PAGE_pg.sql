-- run as
-- psql -h db-dev.devcoffee.cloud  -d mht_cd10 -U adempiere -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Task_TEMPLATE_PAGE_pg.sql > ./docs/script_gen_wiki_files_Task_TEMPLATE_PAGE_pg.sh
-- and then execute the generated script
SELECT
'cat > ./task/'||regexp_replace(unaccent(coalesce(ttrl.name,f.name)), '[^\w]+','','g')||'_Task_ID-'||f.ad_task_id||'_v10.0.0.md <<!
# Tarefa: '||coalesce(ttrl.name,f.name)||' 

**[Criado em:** ' || to_char(f.created,'dd/mm/YYYY') || ' - **Atualizado em:** ' || to_char(f.updated,'dd/mm/YYYY') || ' **]**  
**Descrição:** '||encodehtml(coalesce(coalesce(ttrl.description,f.description),''))||'  
**Ajuda:** '||encodehtml(coalesce(coalesce(ttrl.help,f.help),''))||'

![](/img/system-manual/brerp/'||regexp_replace(unaccent(coalesce(ttrl.name,f.name)), '[^\w]+','','g')||'-Task_BrERP_v10.0.0.png)

!

cp ../static/placeholder.png ../img_all/'||regexp_replace(unaccent(coalesce(ttrl.name,f.name)), '[^\w]+','','g')||'-Task_BrERP_v10.0.0.png
' AS wikitext
--,'en_US_base', m.ad_menu_id, m.ad_task_id, m.NAME,m.description, f.HELP, f.classname, f.ISBETAFUNCTIONALITY
          FROM AD_Menu m, AD_Task f
          LEFT JOIN AD_Task_Trl ttrl ON ttrl.AD_Language = 'pt_BR' and ttrl.ad_task_id = f.ad_task_id
         WHERE --m.ad_menu_id < 1000000
           m.action = 'T'
           AND m.isactive = 'Y'
           AND m.ad_task_id = f.ad_task_id
      ORDER BY f.ad_task_id;
