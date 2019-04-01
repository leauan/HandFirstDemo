begin

--页面注册

sys_function_assign_pkg.service_load('modules/cont/CON651/con_contract_move_cars_select.screen','批量填写',1,1,0);
sys_function_assign_pkg.service_load('modules/cont/CON652/con_contract_move_cars_modify.screen','车辆移库申请维护',1,1,0);

sys_function_assign_pkg.service_load('modules/cont/CON652/con_contract_move_cars_select_wfl.screen','节点批量填写',1,1,0);
sys_function_assign_pkg.service_load('modules/cont/CON652/con_contract_move_cars_detail_wfl.screen','移库申请工作流页面',1,1,0);


--功能定义
sys_function_assign_pkg.func_load('CON652','车辆移库申请维护','','F','modules/cont/CON652/con_contract_move_cars_modify.screen','1','ZHS');
sys_function_assign_pkg.func_load('CON652','车辆移库申请维护','','F','modules/cont/CON652/con_contract_move_cars_modify.screen','1','US');

--功能分配角色, 经销商DF
sys_function_assign_pkg.role_func_load('0613','CON652');

--分配页面
sys_function_assign_pkg.func_service_load('CON651','modules/cont/CON651/con_contract_move_cars_select.screen');

sys_function_assign_pkg.func_service_load('CON652','modules/cont/CON652/con_contract_move_cars_modify.screen');
sys_function_assign_pkg.func_service_load('CON652','modules/cont/CON651/con_contract_move_cars_detail.screen');
sys_function_assign_pkg.func_service_load('CON652','modules/cont/CON651/con_contract_move_cars_select.screen');

-- ZJWFL5120
sys_function_assign_pkg.func_service_load('ZJWFL5120','modules/cont/CON652/con_contract_move_cars_detail_wfl.screen');
sys_function_assign_pkg.func_service_load('ZJWFL5120','modules/cont/CON652/con_contract_move_cars_select_wfl.screen');
--分配bm, bm位置：WEB-INF/classes/
sys_function_assign_pkg.func_bm_load('CON651','cont.CON651.update_agent_id_and_other');
sys_function_assign_pkg.func_bm_load('CON651','cont.CON651.clear_tab_2');

sys_function_assign_pkg.func_bm_load('CON652','cont.CON651.update_agent_id_and_other');
-- cont.CON651.update_agent_id_and_other

sys_function_assign_pkg.func_bm_load('ZJWFL5120','cont.CON651.update_agent_id_and_other');

--菜单定义，参数：p_function_group_code菜单code
sys_load_sys_function_grp_pkg.sys_function_group_item_load(p_function_group_code=>'LEASE_ITEM_DF',p_function_code=>'CON652',p_enabled_flag=>'Y',P_USER_ID=>-1);

end;
/
commit;


