-- run as
-- psql -h db-dev.devcoffee.cloud -d mht_cd10 -U adempiere -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Workflow_TEMPLATE_PAGE_pg.sql > ./docs/script_gen_wiki_files_Workflow_TEMPLATE_PAGE_pg.sh
-- and then execute the generated script
SELECT
'cat > "./workflow/'||regexp_replace(unaccent(coalesce(wtrl.name,f.name)), '[^\w]+','','g')||'_Workflow_ID-'||f.ad_workflow_id||'_v10.0.0.md" <<!
# Fluxo de Trabalho: '||coalesce(wtrl.name,f.name)||' 

**[Criado em:** ' || to_char(f.created,'dd/mm/YYYY') || ' - **Atualizado em:** ' || to_char(f.updated,'dd/mm/YYYY') || ' **]**  
**Descrição:** '||encodehtml(coalesce(coalesce(wtrl.description,f.description),''))||'  
**Ajuda:** '||encodehtml(coalesce(coalesce(wtrl.help,f.help),''))||'

![](/img/system-manual/brerp/'||regexp_replace(unaccent(coalesce(wtrl.name,f.name)), '[^\w]+','','g')||'-Workflow_BrERP_v10.0.0.png)

Tabela: Campos

<table> 
<tr>
<th>Nome</th> 
<th>Descrição</th> 
<th>Ajuda</th>
<th>Tipo</th>
<th>Zoom</th> 
</tr> ' ||
coalesce(nodes.nodes,'')
|| '</table>

!

cp ../static/placeholder.png ../img_all/'||regexp_replace(unaccent(coalesce(wtrl.name,f.name)), '[^\w]+','','g')||'-Workflow_BrERP_v10.0.0.png
' AS wikitext
--,'en_US_base', 'F' AS TYPE, m.ad_menu_id, m.ad_workflow_id, m.NAME,m.description, f.HELP, f.ISBETAFUNCTIONALITY
    FROM AD_Menu m
        JOIN AD_Workflow f ON (m.ad_workflow_id=f.ad_workflow_id)
        LEFT JOIN AD_Workflow_Trl wtrl ON wtrl.AD_language = 'pt_BR' AND wtrl.AD_Workflow_ID = f.AD_Workflow_ID
        LEFT JOIN (
            SELECT n.ad_workflow_id, 
                   string_agg(
                       '<tr><td>' ||coalesce(coalesce(ntrl.name,n.name),'') || '</td>' || 
                       '<td>' ||encodehtml(coalesce(coalesce(ntrl.description,n.description),'')) || '</td>' || 
                       '<td>' ||encodehtml(coalesce(coalesce(ntrl.help,n.help),'')) || '</td>' || 
                       '<td>' ||(SELECT coalesce(name,'') FROM ad_ref_list WHERE ad_reference_id=302 AND value=n.ACTION) || '</td>' || 
                       '<td>' ||coalesce(coalesce(w.NAME,coalesce(p.NAME,coalesce(o.NAME,coalesce(t.NAME,n.NAME)))),'') || '</td></tr>' 
                     , '' ORDER BY tr.depth) AS nodes
                FROM (
                    WITH RECURSIVE nodeswf(ad_workflow_id, ad_wf_node_id, ad_wf_next_id, DEPTH) AS (
                        SELECT w.ad_workflow_id, w.ad_wf_node_id,      wnn.ad_wf_next_id,  1
                            FROM ad_workflow w
                                JOIN ad_wf_nodenext wnn ON wnn.ad_wf_node_id=w.ad_wf_node_id AND wnn.isactive='Y'
                            WHERE w.isactive='Y'
                      UNION
                        SELECT wn.ad_workflow_id, wn.ad_wf_node_id, wnn.ad_wf_next_id, nodeswf.depth+1
                            FROM ad_wf_node wn
                                JOIN nodeswf ON nodeswf.ad_wf_next_id=wn.ad_wf_node_id
                                LEFT JOIN ad_wf_nodenext wnn ON wnn.ad_wf_node_id=wn.ad_wf_node_id AND wnn.isactive='Y'
                        )
                    SELECT * FROM nodeswf
                    ) AS tr
                    JOIN AD_WF_NODE n ON (tr.ad_wf_node_id=n.ad_wf_node_id)
                    LEFT JOIN AD_WF_Node_Trl ntrl ON ntrl.AD_Language = 'pt_BR' AND ntrl.AD_WF_NODE_ID = n.AD_WF_NODE_ID
                    LEFT JOIN AD_WINDOW w USING (ad_window_id)
                    LEFT JOIN AD_PROCESS p USING (ad_process_id)
                    LEFT JOIN AD_FORM o ON (n.ad_form_id=o.ad_form_id)
                    LEFT JOIN AD_TASK t USING (ad_task_id)
                WHERE n.isactive='Y'
                GROUP BY n.ad_workflow_id
             ) AS nodes ON (nodes.ad_workflow_id=f.ad_workflow_id)
    WHERE --m.ad_menu_id < 1000000
         m.action = 'F'
        AND m.isactive = 'Y'
    ORDER BY f.ad_workflow_id;
