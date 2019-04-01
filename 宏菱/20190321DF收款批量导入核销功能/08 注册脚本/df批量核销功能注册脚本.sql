-- df批量核销页面注册脚本
begin

-- 页面注册
sys_function_assign_pkg.service_load('modules/csh/CSH513/csh_transaction_batch_receipt_write_off_detail.screen','df批量核销页面',1,1,0);

-- 分配页面
sys_function_assign_pkg.func_service_load('CSH513','modules/csh/CSH513/csh_transaction_batch_receipt_write_off_detail.screen');

-- 分配bm, bm位置：WEB-INF/classes/csh.CSH513.csh_transaction_batch_query
-- web/WEB-INF/classes/csh/CSH513/csh_write_off_df_tmp_execute.bm
-- web/WEB-INF/classes/csh/CSH513/csh_write_off_df_credit.bm
-- web/WEB-INF/classes/csh/CSH513/csh_transaction_receipt_write_off_df_creditor.bm
-- web/WEB-INF/classes/csh/CSH513/df_workflow_start.bm
sys_function_assign_pkg.func_bm_load('CSH513','csh.CSH513.csh_transaction_batch_query');
sys_function_assign_pkg.func_bm_load('CSH513','csh.CSH513.csh_write_off_df_tmp_execute');
sys_function_assign_pkg.func_bm_load('CSH513','csh.CSH513.csh_write_off_df_credit');
sys_function_assign_pkg.func_bm_load('CSH513','csh.CSH513.csh_transaction_receipt_write_off_df_creditor');
sys_function_assign_pkg.func_bm_load('CSH513','csh.CSH513.df_workflow_start');

end;
/
commit;
