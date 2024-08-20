-- run as
-- psql -h db-dev.devcoffee.cloud  -d mht_cd10 -U adempiere -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Form_TEMPLATE_PAGE_pg.sql > ./docs/script_gen_wiki_files_Form_TEMPLATE_PAGE_pg.sh
-- and then execute the generated script
SELECT
'cat > ./form/'||regexp_replace(unaccent(coalesce(ftrl.name,f.name)), '[^\w]+','','g')||'_Form_ID-'||f.ad_form_id||'_v12.0.0.md <<!
# Formulário: '||coalesce(ftrl.name,f.name)||'

**[Criado em:** ' || to_char(f.created,'dd/mm/YYYY') || ' - **Atualizado em:** ' || to_char(f.updated,'dd/mm/YYYY') || ' **]**  
**Descrição:** '||encodehtml(coalesce(coalesce(ftrl.description,f.description),''))||'  
**Ajuda:** '||encodehtml(coalesce(coalesce(ftrl.help,f.help),''))||'
**Classe:** ['||coalesce(f.classname,'')||'](https://javadoc.brerp.com.br/API/'|| replace(coalesce(f.classname,''),'.','/') || '.html)

![](/img/system-manual/brerp/'||regexp_replace(unaccent(coalesce(ftrl.name,f.name)), '[^\w]+','','g')||'-Form_BrERP_v12.0.0.png)

!

cp -n ../static/placeholder.png ../img_all/'||regexp_replace(unaccent(coalesce(ftrl.name,f.name)), '[^\w]+','','g')||'-Form_BrERP_v12.0.0.png

' AS wikitext
--,'en_US_base', m.ad_menu_id, m.ad_form_id, m.NAME,m.description, f.HELP, f.classname, f.ISBETAFUNCTIONALITY
          FROM AD_MENU m, AD_FORM f
          LEFT JOIN AD_Form_Trl ftrl ON ftrl.AD_Language = 'pt_BR' AND ftrl.AD_Form_ID = f.AD_Form_ID 
         WHERE --m.ad_menu_id < 1000000
           m.action = 'X'
           AND m.isactive = 'Y'
           AND m.ad_form_id = f.ad_form_id
      ORDER BY f.ad_form_id;
