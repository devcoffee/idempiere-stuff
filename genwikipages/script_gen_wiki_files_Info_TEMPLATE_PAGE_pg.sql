
-- run as
-- psql -h db-dev.devcoffee.cloud  -d mht_cd10 -U adempiere -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Info_TEMPLATE_PAGE_pg.sql > ./docs/script_gen_wiki_files_Info_TEMPLATE_PAGE_pg.sh
-- and then execute the generated script
SELECT
'cat > ./info/'||regexp_replace(unaccent(coalesce(itrl.name,f.name)), '[^\w]+','','g')||'_Info_ID-'||f.ad_infowindow_id||'_v12.0.0.md <<!
# Info Window: '||coalesce(itrl.name,f.name)||'

**[Criado em:** ' || to_char(f.created,'dd/mm/YYYY') || ' - **Atualizado em:** ' || to_char(f.updated,'dd/mm/YYYY') || ' **]**  
**Descrição:** '||encodehtml(coalesce(coalesce(itrl.description,f.description),''))||'  
**Ajuda:** '||encodehtml(coalesce(coalesce(itrl.help,f.help),''))||'

![](/img/system-manual/brerp/'||regexp_replace(unaccent(coalesce(itrl.name,f.name)), '[^\w]+','', 'g')||'-Info_BrERP_v12.0.0.png)

!

cp -n ../static/placeholder.png ../img_all/'||regexp_replace(unaccent(coalesce(itrl.name,f.name)), '[^\w]+','', 'g')||'-Info_BrERP_v12.0.0.png

' AS wikitext
--,'en_US_base', m.ad_menu_id, m.ad_infowindow_id, m.NAME,m.description, f.HELP, f.classname, f.ISBETAFUNCTIONALITY
          FROM AD_MENU m, AD_infowindow f
          LEFT JOIN AD_infoWindow_Trl itrl ON itrl.AD_Language = 'pt_BR' AND itrl.ad_infowindow_id = f.ad_infowindow_id 
         WHERE --m.ad_menu_id < 1000000 AND
           m.action = 'I'
           AND m.isactive = 'Y'
           AND m.ad_infowindow_id = f.ad_infowindow_id
      ORDER BY f.ad_infowindow_id;
