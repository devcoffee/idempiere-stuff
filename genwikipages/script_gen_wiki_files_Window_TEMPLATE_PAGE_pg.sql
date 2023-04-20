-- takes 12 minutes
-- run as
-- psql -h db-dev.devcoffee.cloud  -d mht_cd10 -U adempiere -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Window_TEMPLATE_PAGE_pg.sql > ./docs/script_gen_wiki_files_Window_TEMPLATE_PAGE_pg.sh
-- and then execute the generated script

SELECT
'cat <<! | sed -e ''$d'' | sed -e ''$d'' > ./window/'||regexp_replace(unaccent(coalesce(wtrl.name,w.name)), '[^\w]+','','g')||'_Window_ID-'||w.ad_Window_id||'_v10.0.0.md
# Janela: '||coalesce(wtrl.name,w.name)|| '

**[Criado em:** ' || to_char(w.created,'dd/mm/YYYY') || ' - **Atualizado em:** ' || to_char(w.updated,'dd/mm/YYYY') || ' **]**  
**Descrição:** '||encodehtml(coalesce(coalesce(wtrl.description,w.description),''))|| '  
**Ajuda:** '||encodehtml(coalesce(coalesce(wtrl.help,w.help),'')) || '  
![](/img/system-manual/brerp/'||regexp_replace(unaccent(coalesce(wtrl.name,w.name)), '[^\w]+','','g') || '-Window_BrERP_v10.0.0.png)'|| '

' || coalesce(tab.tabs,'') || '

!

cp ../static/placeholder.png ../img_all/'||regexp_replace(unaccent(coalesce(wtrl.name,w.name)), '[^\w]+','','g') || '-Window_BrERP_v10.0.0.png
' AS wikitext
--,ad_language, ad_window_id, ad_tab_id, ad_field_id, TYPE, NAME, description, HELP, seqtab, seqfld, dbtable, dbcolumn, dbtype, adempieretype, ISBETAFUNCTIONALITY
    FROM AD_Menu m
        JOIN AD_Window w ON (m.ad_window_id = w.ad_window_id)
        LEFT JOIN AD_Window_trl wtrl ON wtrl.AD_language = 'pt_BR' AND wtrl.AD_Window_ID = w.AD_Window_ID
        LEFT JOIN (
            SELECT t.ad_window_id, 
                   string_agg('### Aba: '|| coalesce(ttrl.name,t.name) || '

**[Criado em:** ' || to_char(t.created,'dd/mm/YYYY') || ' - **Atualizado em:** ' || to_char(t.updated,'dd/mm/YYYY') || ' **]**   
**Descrição:** ' ||encodehtml(coalesce(coalesce(ttrl.description,t.description),'')) || '  
**Ajuda:** ' ||encodehtml(coalesce(coalesce(ttrl.help,t.help),'')) || '  
**Nível da Aba:** ' ||coalesce(t.tablevel::text,'') || '

Tabela ' || t.seqno || ': ' || coalesce(ttrl.name,t.name) || ' - Campos 

' ||    '<table>' ||
        '<tr>' ||
        '<th>Nome</th>' ||
        '<th>Descrição</th>' ||
        '<th>Ajuda</th>' ||
        '<th>Dados Técnicos</th>'||
        '</tr>' || (SELECT
         string_agg('<tr>'  ||
                        '<td>' || coalesce(f.name,'') || '</td>' ||
                        '<td>' || encodehtml(coalesce(f.description,'')) || '</td>' ||
                        '<td>' || encodehtml(coalesce(f.help,'')) || '</td>' ||
                        '<td> <br> ' || '<small>' ||  '<br/> [' || coalesce(lower(dbtable), '') || '](https://schemaspy.brerp.com.br/adempiere/tables/' || coalesce(lower(dbtable), '') || '.html) ' ||'.'|| coalesce(dbcolumn,'') ||
                                  ' <br/> ' || coalesce(dbtype, '')  ||' <br/> '|| coalesce(adempieretype,'') ||
                                  '</small>' ||
                        '</td>' ||
                       '</tr>' , '' ORDER BY f.seqfld) AS flds
            FROM rv_query_for_manual f
            WHERE f.ad_tab_id=t.ad_tab_id
                AND f.ad_field_id>0
                AND f.ad_language='pt_BR'
        ) || '</table>

'  , '' ORDER BY t.seqno) AS tabs
                FROM ad_tab t
                LEFT JOIN AD_Tab_Trl ttrl ON ttrl.AD_language = 'pt_BR' AND ttrl.AD_Tab_ID = t.Ad_Tab_ID
                WHERE t.isactive='Y'
                GROUP BY t.ad_window_id
             ) AS tab ON (tab.ad_window_id=w.ad_window_id)
    WHERE --m.ad_menu_id < 1000000
         m.action = 'W'
        AND m.isactive = 'Y'
    ORDER BY w.ad_window_id;
