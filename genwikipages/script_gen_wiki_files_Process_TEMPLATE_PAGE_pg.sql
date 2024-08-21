-- run as
-- psql -h db-dev.devcoffee.cloud  -d mht_cd10 -U adempiere -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Process_TEMPLATE_PAGE_pg.sql > ./docs/script_gen_wiki_files_Process_TEMPLATE_PAGE_pg.sh
-- and then execute the generated script
SELECT
'cat > ./process/'||regexp_replace(unaccent(coalesce(ptrl.name,f.name)), '[^\w]+','','g')||'_Process_ID-'||f.ad_process_id||'_v12.0.0.md <<!
# Processo: '|| coalesce(ptrl.name,f.name)||' 

**[Criado em:** ' || to_char(f.created,'dd/mm/YYYY') || ' - **Atualizado em:** ' || to_char(f.updated,'dd/mm/YYYY') || ' **]**  
**Descrição:** '||encodehtml(coalesce(coalesce(ptrl.description,f.description),''))||'  
**Ajuda:** '||encodehtml(coalesce(coalesce(ptrl.help,f.help),''))||'  
**Classe:** ['||coalesce(f.classname,'')||'](https://javadoc.brerp.com.br/API/'|| replace(coalesce(f.classname,''),'.','/') || '.html)

![](/img/system-manual/brerp/'||regexp_replace(unaccent(coalesce(ptrl.name,f.name)), '[^\w]+','','g')||'-Process_BrERP_v12.0.0.png)

' || CASE WHEN (SELECT count(*) FROM ad_process_para pp WHERE pp.ad_process_id=f.ad_process_id AND pp.isactive='Y')>0
THEN 
'Tabela: Parâmetros do Processo
| **Nome** | **Descrição** | **Ajuda** | **Dados Técnicos** |
|----------|---------------|-----------|--------------------|
' || coalesce(prm.params,'') || '' ELSE '' END || '

!

cp -n ../static/placeholder.png ../img_all/'||regexp_replace(unaccent(coalesce(ptrl.name,f.name)), '[^\w]+','','g')||'-Process_BrERP_v12.0.0.png

' AS wikitext
FROM AD_Menu m
JOIN AD_Process f ON (m.ad_process_id = f.ad_process_id)
LEFT JOIN AD_Process_Trl ptrl ON ptrl.AD_Language = 'pt_BR' AND ptrl.ad_process_id = f.ad_process_id 
LEFT JOIN AD_REPORTVIEW rv ON (f.ad_reportview_id = rv.ad_reportview_id)
LEFT JOIN (
    SELECT pp.ad_process_id, 
           string_agg(
            '| ' || coalesce(coalesce(pptrl.name, pp.name), '') || 
            ' | ' || encodehtml(coalesce(coalesce(pptrl.description, pp.description), '')) || 
            ' | ' || encodehtml(coalesce(coalesce(pptrl.help, pp.help), '')) || 
            ' | ' || coalesce(pp.columnname, '') || 
            '<br/>' || coalesce((SELECT r.name FROM ad_reference r WHERE r.validationtype = 'D' AND r.ad_reference_id = pp.ad_reference_id), '') ||
            ' | ' || chr(10), ''
    ORDER BY pp.seqno
) AS params
    FROM AD_PROCESS_PARA pp
    LEFT JOIN AD_PROCESS_PARA_Trl pptrl ON pptrl.AD_Language = 'pt_BR' AND pptrl.ad_process_para_id = pp.ad_process_para_id
    WHERE pp.isactive='Y'
    GROUP BY pp.ad_process_id
) AS prm ON (prm.ad_process_id=f.ad_process_id)
WHERE --m.ad_menu_id < 1000000 AND
         m.action = 'P'
AND m.isactive = 'Y'
ORDER BY f.ad_process_id;
