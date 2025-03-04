SELECT     n.node_id, n.parent_id, n.depth, n.seqno,
           m.issummary,
	   -- rpad('>', depth-1, '>') ||
				CASE m.action
                        -- WHEN 'B' THEN 'Workbench'
                         WHEN 'F' THEN replace(coalesce(ftrl.name,f.name), ',', '|')
                         WHEN 'P' THEN replace(coalesce(ptrl.name,p.name), ',', '|')
                         WHEN 'R' THEN replace(coalesce(ptrl.name,p.name), ',', '|')
                         WHEN 'T' THEN replace(coalesce(ttrl.name,t.name), ',', '|')
                         WHEN 'W' THEN replace(coalesce(wtrl.name,w.name), ',', '|')
                         WHEN 'X' THEN replace(coalesce(xtrl.name,x.name), ',', '|')
                         WHEN 'I' THEN replace(coalesce(itrl.name,i.name), ',', '|')
                         ELSE replace(coalesce(mtrl.name,m.name), ',', '|')
                END AS name,
                COALESCE(m.action, '') AS TYPE,
                CASE m.action
                         WHEN 'B' THEN 'Workbench'
                         WHEN 'F' THEN 'Workflow'
                         WHEN 'P' THEN 'Process'
                         WHEN 'R' THEN 'Report'
                         WHEN 'T' THEN 'Task'
                         WHEN 'W' THEN 'Window'
                         WHEN 'X' THEN 'Form'
                         WHEN 'I' THEN 'Info'
                         ELSE 'Menu'
                END AS action,
                COALESCE
                    ('[' || x.classname || '](https://javadoc.brerp.com.br/API/' || replace(x.classname,'.','/') || '.html)',
                     COALESCE ('[' || p.classname || '](https://javadoc.brerp.com.br/API/' || replace(p.classname,'.','/') || '.html)',
                          COALESCE (p.procedurename,
                               COALESCE (t.os_command,
                                    COALESCE (REPLACE(i.fromclause,chr(10),' '),
                                         qss_get_tables_from_window (m.ad_window_id)
                                        )
                                   )
                              )
                         )
                    ) AS technical,
                 coalesce(p.ad_process_id, x.ad_form_id, t.ad_task_id, w.ad_window_id, f.ad_workflow_id, i.ad_infowindow_id) as id,
                 COALESCE(COALESCE(x.isbetafunctionality, COALESCE(p.isbetafunctionality, COALESCE(f.isbetafunctionality, w.isbetafunctionality), ''))) as isbetafunctionality,
                 CASE m.action
                        -- WHEN 'B' THEN 'Workbench'
                         WHEN 'F' THEN regexp_replace(unaccent(replace(coalesce(ftrl.name,f.name), ',', '|')), '[^\w]+','','g')
                         WHEN 'P' THEN regexp_replace(unaccent(replace(coalesce(ptrl.name,p.name), ',', '|')), '[^\w]+','','g')
                         WHEN 'R' THEN regexp_replace(unaccent(replace(coalesce(ptrl.name,p.name), ',', '|')), '[^\w]+','','g')
                         WHEN 'T' THEN regexp_replace(unaccent(replace(coalesce(ttrl.name,t.name), ',', '|')), '[^\w]+','','g')
                         WHEN 'W' THEN regexp_replace(unaccent(replace(coalesce(wtrl.name,w.name), ',', '|')), '[^\w]+','','g')
                         WHEN 'X' THEN regexp_replace(unaccent(replace(coalesce(xtrl.name,x.name), ',', '|')), '[^\w]+','','g')
                         WHEN 'I' THEN regexp_replace(unaccent(replace(coalesce(itrl.name,i.name), ',', '|')), '[^\w]+','','g')
                         ELSE regexp_replace(unaccent(replace(coalesce(mtrl.name,m.name), ',', '|')), '[^\w]+','','g')
                 END AS name_encoded,             
                 n.path
            FROM (
  with recursive fullmenu(node_id, parent_id, depth, seqno, path) as (
    select n.node_id, n.parent_id, 1, n.seqno, ARRAY[row(n.seqno,n.node_id)] from ad_treenodemm n where ad_tree_id=10 and n.parent_id=0
    union all
    select n.node_id, n.parent_id, fm.depth+1, n.seqno, path || row(n.seqno,n.node_id) from ad_treenodemm n join fullmenu fm on fm.node_id = n.parent_id where ad_tree_id=10
    )
  select * from fullmenu
)
as n
                 JOIN AD_MENU m ON n.node_id = m.ad_menu_id
                 LEFT JOIN AD_Menu_Trl mtrl ON mtrl.AD_Language = 'pt_BR' AND mtrl.ad_menu_id = m.ad_menu_id
                 LEFT JOIN AD_PROCESS    p ON m.ad_process_id = p.ad_process_id AND p.isactive='Y'
                 LEFT JOIN AD_Process_Trl ptrl ON ptrl.AD_Language = 'pt_BR' AND ptrl.ad_process_id = p.ad_process_id
                 LEFT JOIN AD_FORM       x ON m.ad_form_id = x.ad_form_id AND x.isactive='Y'
                 LEFT JOIN AD_FORM_Trl xtrl ON xtrl.AD_Language = 'pt_BR' AND xtrl.ad_form_id = x.ad_form_id
                 LEFT JOIN AD_TASK       t ON m.ad_task_id = t.ad_task_id AND t.isactive='Y'
                 LEFT JOIN AD_Task_Trl ttrl ON ttrl.AD_Language = 'pt_BR' AND ttrl.ad_task_id = t.ad_task_id
                 LEFT JOIN AD_WINDOW     w ON m.ad_window_id = w.ad_window_id AND w.isactive='Y'
                 LEFT JOIN AD_Window_Trl wtrl ON wtrl.AD_Language = 'pt_BR' AND wtrl.ad_window_id = w.ad_window_id
                 LEFT JOIN AD_WORKFLOW   f ON m.ad_workflow_id = f.ad_workflow_id AND f.isactive='Y'
                 LEFT JOIN AD_Workflow_Trl ftrl ON ftrl.AD_Language = 'pt_BR' AND ftrl.ad_workflow_id = f.ad_workflow_id
                 LEFT JOIN AD_INFOWINDOW i ON m.ad_infowindow_id = i.ad_infowindow_id AND i.isactive='Y'
                 LEFT JOIN AD_InfoWindow_Trl itrl ON itrl.AD_Language = 'pt_BR' AND itrl.ad_infowindow_id = i.ad_infowindow_id
                 -- uncomment next 7 lines and replace roleID for specific role menu
                 --LEFT JOIN AD_Role r ON AD_Role_ID=102
                 --LEFT JOIN AD_Process_Access    pa ON pa.AD_Role_ID=r.AD_Role_ID AND pa.IsActive='Y' AND pa.AD_Process_ID=p.AD_Process_ID
                 --LEFT JOIN AD_Form_Access       xa ON xa.AD_Role_ID=r.AD_Role_ID AND xa.IsActive='Y' AND xa.AD_Form_ID=x.AD_Form_ID
                 --LEFT JOIN AD_Task_Access       ta ON ta.AD_Role_ID=r.AD_Role_ID AND ta.IsActive='Y' AND ta.AD_Task_ID=t.AD_Task_ID
                 --LEFT JOIN AD_Window_Access     wa ON wa.AD_Role_ID=r.AD_Role_ID AND wa.IsActive='Y' AND wa.AD_Window_ID=w.AD_Window_ID
                 --LEFT JOIN AD_Workflow_Access   fa ON fa.AD_Role_ID=r.AD_Role_ID AND fa.IsActive='Y' AND fa.AD_Workflow_ID=f.AD_Workflow_ID
                 --LEFT JOIN AD_InfoWindow_Access ia ON ia.AD_Role_ID=r.AD_Role_ID AND ia.IsActive='Y' AND ia.AD_InfoWindow_ID=i.AD_InfoWindow_ID
           WHERE m.isactive = 'Y'
             -- uncomment next for just official entries
             -- and m.ad_menu_id < 1000000
             -- uncomment next for specific role
             --and (action is null or coalesce(pa.isactive,coalesce(xa.isactive,coalesce(ta.isactive,coalesce(wa.isactive,coalesce(fa.isactive,ia.isactive))))) is not null)
order by n.path
