Create Or Replace Package con_df_car_confirm_pkg Is

  -- Author  : 吴团森
  -- Created : 2018/12/25 13:54:16
  -- Purpose : 

  Procedure delete_inventory_info_check(p_inventory_id Number,
                                        p_user_id      Number);

  Procedure update_agent_inventory_id(p_car_info_id        Number,
                                      p_agent_inventory_id Number,
                                      p_user_id            Number);
  Procedure update_status_to_stock_in(p_car_info_id Number,
                                      p_user_id     Number);
  --批量
  Procedure update_agent_id_and_confirm(p_car_info_id        Number,
                                        p_agent_inventory_id Number,
                                        p_user_id            Number);
  Procedure clear_tab_2(p_car_info_id Number,
                        p_flag        Varchar2,
                        p_user_id     Number);
  Procedure ins_con_move_cars_hd(p_hd_id Out Number, p_user_id Number);
  Procedure ins_con_move_cars_ln(p_hd_id       Number,
                                 p_car_info_id Number,
                                 p_user_id     Number);
  --车辆移库工作流启动
  Procedure con_move_cars_wfl_start(p_hd_id Number, p_user_id Number);
  --车辆移库工作流结束
  Procedure con_move_cars_wfl_end(p_hd_id   Number,
                                  p_status  Varchar2,
                                  p_user_id Number);

  Procedure update_agent_id_and_other(p_ln_id          Number,
                                      p_after_id       Number,
                                      p_move_date      Date,
                                      p_remove_date    Date,
                                      p_phone          Varchar2,
                                      p_contact_person Varchar2,
                                      p_user_id        Number);

  Procedure cancel_apply_for_move(p_hd_id Number, p_user_id Number);

  Procedure update_move_cars_for_wfl(p_ln_id        Number,
                                     p_deposit_flag Varchar2,
                                     p_user_id      Number);

  Procedure check_deposit_flag(p_hd_id Number, p_user_id Number);

  Procedure df_permission_check(p_user_id Number);
End con_df_car_confirm_pkg;
/
Create Or Replace Package Body con_df_car_confirm_pkg Is
  e_lock_table Exception;

  Procedure delete_inventory_info_check(p_inventory_id Number,
                                        p_user_id      Number) Is
  
    v_count Number;
    e_exists Exception;
  Begin
    Select Count(1)
      Into v_count
      From con_contract_df_car_info
     Where AGENT_INVENTORY_ID = p_inventory_id;
    If v_count > 0 Then
      Raise e_exists;
    End If;
  Exception
    When e_exists Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => '存在车辆接收使用该库点',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'delete_inventory_info_check');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    
  End;
  Procedure update_con_df_car_info(p_df_car_info_rec con_contract_df_car_info%Rowtype) Is
    v_prj_car_id Number;
  Begin
    Update con_contract_df_car_info
       Set Row = p_df_car_info_rec
     Where car_info_id = p_df_car_info_rec.car_info_id;
  
    Select pp.car_info_id
      Into v_prj_car_id
      From prj_project_df_car_info pp
     Where nvl(pp.contract_id, p_df_car_info_rec.contract_id) =
           p_df_car_info_rec.contract_id
       And pp.son_code = p_df_car_info_rec.son_code;
  
    --合同车辆信息更新后，需同步更新至项目信息
    hls_document_transfer_pkg.doc_to_doc(p_from_doc_table => 'CON_CONTRACT_DF_CAR_INFO',
                                         p_from_doc_pk    => p_df_car_info_rec.car_info_id,
                                         p_to_doc_table   => 'PRJ_PROJECT_DF_CAR_INFO',
                                         p_to_doc_pk      => v_prj_car_id,
                                         p_copy_method    => 'DOC_TO_HISTORY',
                                         p_user_id        => p_df_car_info_rec.last_updated_by);
  End;

  --modify by lara 11355 若监管方已维护库点地址则不做级联
  Procedure update_agent_inventory_id(p_car_info_id        Number,
                                      p_agent_inventory_id Number,
                                      p_user_id            Number) Is
    r_con_df_car_cur con_contract_df_car_info%Rowtype;
    e_status Exception;
  Begin
  
    Select *
      Into r_con_df_car_cur
      From con_contract_df_car_info
     Where car_info_id = p_car_info_id;
    --判断状态
    If r_con_df_car_cur.car_status Not In ('STOCK_OUT') Then
      Raise e_status;
    End If;
    --更新
    If r_con_df_car_cur.regulator_inventory_id Is Null Then
      Update con_contract_df_car_info cd
         Set cd.agent_inventory_id     = p_agent_inventory_id,
             cd.regulator_inventory_id = p_agent_inventory_id,
             cd.last_updated_by        = p_user_id,
             cd.last_update_date       = Sysdate
       Where car_info_id = p_car_info_id;
    Else
      Update con_contract_df_car_info cd
         Set cd.agent_inventory_id = p_agent_inventory_id,
             cd.last_updated_by    = p_user_id,
             cd.last_update_date   = Sysdate
       Where car_info_id = p_car_info_id;
    End If;
    --end modify by lara 11355
  Exception
    When e_status Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => '状态有误，仅可维护状态为<已出库>的库点信息！',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'save_before_check');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    
  End;

  Procedure update_status_to_stock_in(p_car_info_id Number,
                                      p_user_id     Number) Is
    e_status    Exception;
    e_inventory Exception;
    v_car_status         Varchar2(30);
    v_agent_inventory_id Number;
    r_df_car_info_rec    con_contract_df_car_info%Rowtype;
  Begin
    Select car_status
      Into v_car_status
      From con_contract_df_car_info
     Where car_info_id = p_car_info_id;
  
    Select agent_inventory_id
      Into v_agent_inventory_id
      From con_contract_df_car_info
     Where car_info_id = p_car_info_id;
  
    --库点信息必填才能确认
    If v_agent_inventory_id Is Null Then
      Raise e_inventory;
    End If;
  
    --状态确认
    If v_car_status Not In ('STOCK_OUT') Then
      Raise e_status;
    End If;
    Update con_contract_df_car_info
       Set car_status       = 'STOCK_IN',
           last_updated_by  = p_user_id,
           last_update_date = Sysdate
     Where car_info_id = p_car_info_id;
  
    Select *
      Into r_df_car_info_rec
      From con_contract_df_car_info
     Where car_info_id = p_car_info_id;
  
    update_con_df_car_info(p_df_car_info_rec => r_df_car_info_rec);
  Exception
    When e_status Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => '状态有误，仅可确认 已出库的车辆！',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'update_status_to_stock_in');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    
    When e_inventory Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => '未维护库点信息！',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'update_status_to_stock_in');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    
  End;

  --批量
  Procedure update_agent_id_and_confirm(p_car_info_id        Number,
                                        p_agent_inventory_id Number,
                                        p_user_id            Number) Is
    v_car_status Varchar2(30);
    e_status Exception;
  Begin
    update_agent_inventory_id(p_car_info_id        => p_car_info_id,
                              p_agent_inventory_id => p_agent_inventory_id,
                              p_user_id            => p_user_id);
    update_status_to_stock_in(p_car_info_id => p_car_info_id,
                              p_user_id     => p_user_id);
  End;

  Procedure clear_tab_2(p_car_info_id Number,
                        p_flag        Varchar2,
                        p_user_id     Number) Is
  
  Begin
    Update con_contract_df_car_info
       Set will_move_flag   = p_flag,
           last_updated_by  = p_user_id,
           last_update_date = Sysdate
     Where car_info_id = p_car_info_id;
  End;
  Function get_from_pk(p_document_history_id In Number,
                       p_table_name          In Varchar2,
                       p_to_doc_pk           In Number) Return Number Is
    v_from_doc_pk Number;
  Begin
    Select from_pk_id
      Into v_from_doc_pk
      From hls_document_history_ref
     Where document_history_id = p_document_history_id
       And table_name = p_table_name
       And to_pk_id = p_to_doc_pk;
    Return v_from_doc_pk;
  Exception
    When no_data_found Then
      Return Null;
  End;

  Function get_con_contract_rec(p_contract_id Number,
                                p_user_id     Number,
                                p_batch_id    Number Default Null)
    Return con_contract%Rowtype Is
    v_con_contract_rec con_contract%Rowtype;
  Begin
    Select *
      Into v_con_contract_rec
      From con_contract c
     Where c.contract_id = p_contract_id
       For Update Nowait;
    Return v_con_contract_rec;
  Exception
    When e_lock_table Then
      If p_batch_id Is Not Null Then
        Delete con_redemption_certificate Where batch_id = p_batch_id;
      End If;
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => '资源正忙！',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_redemption_certificate_pkg',
                                                     p_procedure_function_name => 'get_con_contract_rec');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
  End;

  Procedure ins_con_move_cars_hd(p_hd_id Out Number, p_user_id Number) Is
    v_hd_id     Number;
    v_hd_number con_move_cars_hd.hd_number%Type;
  Begin
    v_hd_id := con_move_cars_hd_s.nextval;
    -- add by CLiyuan
    v_hd_number := fnd_code_rule_pkg.get_rule_next_auto_num(p_document_category => 'CONTRACT',
                                                            p_document_type     => 'MOVE_CARS',
                                                            p_company_id        => 1,
                                                            p_operation_unit_id => Null,
                                                            p_operation_date    => Sysdate,
                                                            p_created_by        => p_user_id);
  
    Insert Into con_move_cars_hd
      (hd_id,
       hd_number,
       user_id,
       status,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by)
    Values
      (v_hd_id,
       v_hd_number,
       p_user_id,
       'NEW',
       Sysdate,
       p_user_id,
       Sysdate,
       p_user_id);
    p_hd_id := v_hd_id;
  End;

  Procedure ins_con_move_cars_ln(p_hd_id       Number,
                                 p_car_info_id Number,
                                 p_user_id     Number) Is
    v_contract_id          Number;
    v_vin_code             Varchar2(200);
    v_orgal_inventory_id   Number;
    v_count                Number;
    v_finance_amount       Number;
    v_early_redemp_payment Number; -- 移库保证金
    v_sum_amount           Number;
    v_due_amount           Number;
    v_moved_flag           Varchar2(1);
    E_EXISTS_SUBMIT   Exception;
    E_ABNORMAL_AMOUNT Exception;
  Begin
    Select ci.contract_id,
           ci.item_frame_number,
           ci.agent_inventory_id,
           nvl(ci.finance_amount, 0),
           round(nvl(ci.finance_amount * hb.transfer_margin_ratio, 0), 2)
      Into v_contract_id,
           v_vin_code,
           v_orgal_inventory_id,
           v_finance_amount,
           v_early_redemp_payment -- 移库保证金
      From con_contract_df_car_info ci, hls_bp_master hb
     Where ci.bp_id = hb.bp_id
       And car_info_id = p_car_info_id;
    -- 是否移过库 
    For ln_cur In (Select *
                     From con_move_cars_ln ln
                    Where ln.contract_id = v_contract_id) Loop
      If ln_cur.is_moved_flag = 'Y' Then
        v_moved_flag := 'Y';
        Exit;
      Else
        v_moved_flag := 'N';
      End If;
    End Loop;
    
    Select Count(1)
      Into v_count
      From con_move_cars_ln ln
     Where car_info_id = p_car_info_id
       And Exists (Select 1
              From con_move_cars_hd
             Where hd_id = ln.hd_id
               And status In ('APPROVING'));
    If v_count > 0 Then
      Raise E_EXISTS_SUBMIT;
    End If;
    Insert Into con_move_cars_ln
      (line_id,
       hd_id,
       car_info_id,
       contract_id,
       before_id,
       early_redemp_payment, -- 移库保证金
       redemp_payment, -- 保理融资额
       is_moved_flag,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by)
    Values
      (con_move_cars_ln_s.nextval,
       p_hd_id,
       p_car_info_id,
       v_contract_id,
       v_orgal_inventory_id,
       v_early_redemp_payment, -- 移库保证金
       v_finance_amount, -- 保理融资额
       nvl(v_moved_flag, 'N'),
       Sysdate,
       p_user_id,
       Sysdate,
       p_user_id);
    -- 更新合同状态 add by CLiyuan
    Update con_contract_df_car_info c
       Set c.car_status = 'MOVING'
     Where c.contract_id = v_contract_id;
    -- 插表之后进行金额判断
    Select Sum(nvl(cl.early_redemp_payment, 0))
      Into v_sum_amount -- 赎证保证金总额
      From con_move_cars_ln cl
     Where cl.car_info_id = p_car_info_id
       And cl.contract_id = v_contract_id;
  
    Select nvl(cc.due_amount, 0)
      Into v_due_amount -- 赎证款
      From con_contract_cashflow cc
     Where cc.contract_id = v_contract_id
       And cc.cf_item = '302'
       And cc.cf_status = 'RELEASE';
  
    If v_due_amount - v_sum_amount < v_early_redemp_payment Then
      Raise E_ABNORMAL_AMOUNT;
    End If;
  
  Exception
    When E_EXISTS_SUBMIT Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => v_vin_code ||
                                                                                  '已在申请移库中',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'ins_con_move_cars_ln');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    When E_ABNORMAL_AMOUNT Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => v_vin_code ||
                                                                                  '移库次数已超出限制，无法再进行移库！',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'ins_con_move_cars_ln');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    When Others Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => dbms_utility.format_error_backtrace || ' ' ||
                                                                                  Sqlerrm,
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'ins_con_move_cars_ln');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
  End;
  Procedure restore_con_history(p_contract_id Number,
                                p_hd_id       Number,
                                p_user_id     Number) Is
    v_con_contract_rec    con_contract%Rowtype;
    v_version             Varchar2(10);
    v_document_history_id Number;
    v_new_contract_id     Number;
    doc_pk_list           hls_document_transfer_pkg.t_doc_pk_list;
    doc_pk_list_1         hls_document_transfer_pkg.t_doc_pk_list;
    i                     Number;
    j                     Number;
    v_fee_id              Number;
    v_cashflow_id         Number;
    v_car_info_id         Number;
  Begin
    v_con_contract_rec := get_con_contract_rec(p_contract_id, p_user_id);
    hls_document_history_pkg.create_document_history(p_document_category   => 'CON_CONTRACT',
                                                     p_document_id         => p_contract_id,
                                                     p_usage_code          => 'HISTORY',
                                                     p_data_class          => 'HISTORY',
                                                     p_history_doc_status  => v_con_contract_rec.contract_status,
                                                     p_user_id             => p_user_id,
                                                     p_document_history_id => v_document_history_id,
                                                     p_version             => v_version);
  
    v_new_contract_id := v_document_history_id;
    hls_document_transfer_pkg.doc_to_doc(p_from_doc_table        => 'CON_CONTRACT',
                                         p_from_doc_pk           => p_contract_id,
                                         p_to_doc_table          => 'CON_CONTRACT',
                                         p_to_doc_pk             => v_new_contract_id,
                                         p_copy_method           => 'DOC_TO_HISTORY',
                                         p_to_doc_column_1       => 'data_class',
                                         p_to_doc_column_1_value => 'HISTORY',
                                         p_user_id               => p_user_id);
    hls_document_history_pkg.create_document_history_ref(p_document_history_id => v_document_history_id,
                                                         p_table_name          => 'CON_CONTRACT',
                                                         p_from_pk_id          => p_contract_id,
                                                         p_to_pk_id            => v_new_contract_id,
                                                         p_user_id             => p_user_id);
  
    --现金流             
    doc_pk_list_1.delete;
    j := 0;
    For cur_cf In (Select *
                     From con_contract_cashflow cf
                    Where cf.contract_id = p_contract_id) Loop
      j := j + 1;
      Select con_contract_cashflow_s.nextval Into v_cashflow_id From dual;
      doc_pk_list_1(j).from_doc_pk := cur_cf.cashflow_id;
      doc_pk_list_1(j).to_doc_pk := v_cashflow_id;
      hls_document_history_pkg.create_document_history_ref(p_document_history_id => v_document_history_id,
                                                           p_table_name          => 'CON_CONTRACT_CASHFLOW',
                                                           p_from_pk_id          => cur_cf.cashflow_id,
                                                           p_to_pk_id            => v_cashflow_id,
                                                           p_user_id             => p_user_id);
    
    End Loop;
    hls_document_transfer_pkg.doc_to_doc(p_from_doc_table        => 'CON_CONTRACT_CASHFLOW',
                                         p_to_doc_table          => 'CON_CONTRACT_CASHFLOW',
                                         p_doc_pk_list           => doc_pk_list_1,
                                         p_copy_method           => 'DOC_TO_HISTORY',
                                         p_to_doc_column_1       => 'contract_id',
                                         p_to_doc_column_1_value => v_new_contract_id,
                                         p_user_id               => p_user_id);
    --DF租赁物con_contract_df_car_info
  
    doc_pk_list_1.delete;
    j := 0;
    For cur_ci In (Select *
                     From con_contract_df_car_info ci
                    Where ci.contract_id = p_contract_id) Loop
      j := j + 1;
      Select con_contract_df_car_info_s.nextval
        Into v_car_info_id
        From dual;
      doc_pk_list_1(j).from_doc_pk := cur_ci.car_info_id;
      doc_pk_list_1(j).to_doc_pk := v_car_info_id;
      hls_document_history_pkg.create_document_history_ref(p_document_history_id => v_document_history_id,
                                                           p_table_name          => 'CON_CONTRACT_DF_CAR_INFO',
                                                           p_from_pk_id          => cur_ci.car_info_id,
                                                           p_to_pk_id            => v_car_info_id,
                                                           p_user_id             => p_user_id);
    
    End Loop;
    hls_document_transfer_pkg.doc_to_doc(p_from_doc_table        => 'CON_CONTRACT_DF_CAR_INFO',
                                         p_to_doc_table          => 'CON_CONTRACT_DF_CAR_INFO',
                                         p_doc_pk_list           => doc_pk_list_1,
                                         p_copy_method           => 'DOC_TO_HISTORY',
                                         p_to_doc_column_1       => 'contract_id',
                                         p_to_doc_column_1_value => v_new_contract_id,
                                         p_user_id               => p_user_id);
    Update con_move_cars_ln
       Set history_id = v_new_contract_id
     Where hd_id = p_hd_id
       And contract_id = p_contract_id;
  End;

  Procedure recalc_con_cashflow(p_line_id Number) Is
    r_con_move_cars_ln con_move_cars_ln%Rowtype;
  Begin
    Select *
      Into r_con_move_cars_ln
      From con_move_cars_ln
     Where line_id = p_line_id;
  
  End;

  Procedure con_move_cars_wfl_before(p_hd_id Number, p_user_id Number) Is
    v_document_id         Number;
    v_con_contract_rec    con_contract%Rowtype;
    v_document_history_id Number;
    v_new_contract_id     Number;
    v_data_class          Varchar2(50);
    doc_pk_list           hls_document_transfer_pkg.t_doc_pk_list;
    doc_pk_list_1         hls_document_transfer_pkg.t_doc_pk_list;
    doc_pk_list_2         hls_document_transfer_pkg.t_doc_pk_list;
    i                     Number;
    j                     Number;
    v_version             Number;
    v_document_category   Varchar2(200);
    v_cashflow_id         Number;
  Begin
  
    For cur_con In (Select *
                      From con_move_cars_ln ln
                     Where hd_id = p_hd_id
                       And nvl(ln.early_redemp_payment, 0) > 0) Loop
      restore_con_history(p_contract_id => cur_con.contract_id,
                          p_hd_id       => p_hd_id,
                          p_user_id     => p_user_id);
    
    End Loop;
  End;

  --车辆移库工作流启动
  Procedure con_move_cars_wfl_start(p_hd_id Number, p_user_id Number) Is
    r_document    con_move_cars_hd%Rowtype;
    v_instance_id Number;
    e_status       Exception; --状态错误异常
    e_confirm_flag Exception; --确认标识
    v_agent_name  Varchar2(200);
    v_company_id  Number;
    v_final_count Number;
    v_user_name   Varchar2(200);
  Begin
    Select pur.*
      Into r_document
      From con_move_cars_hd pur
     Where pur.hd_id = p_hd_id;
    If nvl(r_document.status, 'NEW') Not In ('NEW', 'REJECT') Then
      --如果状态有问题，抛出状态异常错误
      Raise e_status;
    End If;
    Select sy.description
      Into v_user_name
      From sys_user sy
     Where sy.user_id = p_user_id;
    /* con_move_cars_wfl_before(p_hd_id => p_hd_id, p_user_id => p_user_id);*/
  
    v_company_id := 1; --默认公司 
    Update con_move_cars_hd l
       Set l.status           = 'APPROVING',
           l.last_updated_by  = p_user_id,
           l.last_update_date = Sysdate
     Where l.hd_id = p_hd_id;
  
    v_instance_id := r_document.instance_id;
  
    /*发起工作流*/
    hls_workflow_pkg.workflow_start(p_instance_id       => v_instance_id,
                                    p_document_category => 'CONTRACT',
                                    p_document_type     => 'MOVE_CARS',
                                    p_company_id        => v_company_id,
                                    p_user_id           => p_user_id,
                                    p_function_code     => 'CON651',
                                    p_parameter_1       => 'HD_ID',
                                    p_parameter_1_value => p_hd_id,
                                    p_parameter_2       => 'DOCUMENT_INFO',
                                    p_parameter_2_value => r_document.hd_number || '-' ||
                                                           v_user_name ||
                                                           '提交赎证申请',
                                    p_parameter_3       => 'SUBMITTED_BY',
                                    p_parameter_3_value => p_user_id);
  
    --发起工作流后更新实例ID
    Update con_move_cars_hd l
       Set l.instance_id = v_instance_id
     Where l.hd_id = p_hd_id;
  Exception
    When e_status Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => '只有新建、拒绝的单据可以提交审批，请检查单据状态',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'con_move_cars_wfl_start');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    When Others Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => dbms_utility.format_error_backtrace || ' ' ||
                                                                                  Sqlerrm,
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'con_move_cars_wfl_start');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
  End con_move_cars_wfl_start;

  --还原现金流
  Procedure restore_history_to_con(p_contract_id Number,
                                   p_history_id  Number,
                                   p_user_id     Number) Is
    r_change              hls_document_history%Rowtype;
    v_from_pk             Number;
    v_from_repay_id       Number;
    v_history_id          Number;
    r_document            con_contract%Rowtype;
    v_version             Varchar2(10);
    v_document_history_id Number;
    v_new_contract_id     Number;
    doc_pk_list           hls_document_transfer_pkg.t_doc_pk_list;
    doc_pk_list_1         hls_document_transfer_pkg.t_doc_pk_list;
    i                     Number;
    j                     Number;
    v_new_cashflow_id     Number;
    v_car_info_id         Number;
  Begin
    --现金流
    Delete con_contract_cashflow Where contract_id = p_contract_id;
    doc_pk_list_1.delete;
    j := 0;
    For cur_cf In (Select *
                     From con_contract_cashflow cf
                    Where cf.contract_id = p_history_id) Loop
      j                 := j + 1;
      v_new_cashflow_id := get_from_pk(p_document_history_id => p_history_id,
                                       p_table_name          => 'CON_CONTRACT_CASHFLOW',
                                       p_to_doc_pk           => cur_cf.cashflow_id);
      If v_new_cashflow_id Is Null Then
        Select con_contract_cashflow_s.nextval
          Into v_new_cashflow_id
          From dual;
      End If;
      doc_pk_list_1(j).from_doc_pk := cur_cf.cashflow_id;
      doc_pk_list_1(j).to_doc_pk := v_new_cashflow_id;
    End Loop;
    hls_document_transfer_pkg.doc_to_doc(p_from_doc_table        => 'CON_CONTRACT_CASHFLOW',
                                         p_to_doc_table          => 'CON_CONTRACT_CASHFLOW',
                                         p_doc_pk_list           => doc_pk_list_1,
                                         p_copy_method           => 'DOC_TO_HISTORY',
                                         p_to_doc_column_1       => 'contract_id',
                                         p_to_doc_column_1_value => p_contract_id,
                                         p_user_id               => p_user_id);
  
  End;
  Procedure ins_con_cashflow(p_contract_id Number, p_user_id Number) Is
    v_finance_Amount        Number;
    V_TRANSFER_MARGIN_RATIO Number;
    v_bp_id                 Number;
    v_amount                Number;
    v_times                 Number;
  Begin
    Select bp_id_tenant
      Into v_bp_id
      From con_contract
     Where contract_id = p_contract_id;
    Select due_amount
      Into v_finance_Amount
      From con_contract_cashflow
     Where contract_id = p_contract_id
       And cf_item = 300
       And cf_status = 'RELEASE';
    Select TRANSFER_MARGIN_RATIO
      Into V_TRANSFER_MARGIN_RATIO
      From hls_bp_master
     Where bp_id = v_bp_id;
  
    If nvl(V_TRANSFER_MARGIN_RATIO, 0) = 0 Then
      Return;
    End If;
    v_amount := v_finance_Amount * V_TRANSFER_MARGIN_RATIO;
  
    Select Max(times)
      Into v_times
      From con_contract_cashflow
     Where cf_item = 304
       And cf_status = 'RELEASE'
       And contract_id = p_contract_id;
  
    v_times := nvl(v_times, 0) + 1;
    --插入移库保证金退回(305)
    Insert Into con_contract_cashflow
      (cashflow_id,
       contract_id,
       cf_item,
       cf_type,
       cf_direction,
       cf_status,
       times,
       calc_date,
       due_date,
       fin_income_date,
       due_amount,
       principal,
       write_off_flag,
       overdue_status,
       penalty_process_status,
       billing_status,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date)
    Values
      (con_contract_cashflow_s.nextval,
       p_contract_id,
       305,
       300,
       'OUTFLOW',
       'RELEASE',
       v_times,
       Sysdate,
       Sysdate,
       Sysdate,
       v_amount,
       v_amount,
       'NOT',
       'N',
       'NORMAL',
       'NOT',
       p_user_id,
       Sysdate,
       p_user_id,
       Sysdate);
    --插入移库保证金(304)
    Insert Into con_contract_cashflow
      (cashflow_id,
       contract_id,
       cf_item,
       cf_type,
       cf_direction,
       cf_status,
       times,
       calc_date,
       due_date,
       fin_income_date,
       due_amount,
       principal,
       write_off_flag,
       overdue_status,
       penalty_process_status,
       billing_status,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date)
    Values
      (con_contract_cashflow_s.nextval,
       p_contract_id,
       304,
       300,
       'INFLOW',
       'RELEASE',
       v_times,
       Sysdate,
       Sysdate,
       Sysdate,
       v_amount,
       v_amount,
       'NOT',
       'N',
       'NORMAL',
       'NOT',
       p_user_id,
       Sysdate,
       p_user_id,
       Sysdate);
  
  End;
  --车辆移库工作流结束
  Procedure con_move_cars_wfl_end(p_hd_id   Number,
                                  p_status  Varchar2,
                                  p_user_id Number) Is
    r_document             con_move_cars_hd%Rowtype;
    v_linkage_month_num    Number;
    v_write_off_id         Number;
    v_reverse_write_off_id Number;
    v_max_times            Number;
    v_son_code             Varchar2(100);
  Begin
    Update con_move_cars_hd t
       Set t.status           = p_status,
           t.last_update_date = Sysdate,
           t.last_updated_by  = p_user_id
     Where t.hd_id = p_hd_id;
    If p_status = 'APPROVED' Then
      --如果审批通过
      For cur_ln In (Select * From con_move_cars_ln Where hd_id = p_hd_id) Loop
        -- 更新车辆移库信息
        Update con_contract_df_car_info cd
           Set cd.agent_inventory_id     = cur_ln.after_id,
               cd.regulator_inventory_id = cur_ln.after_id,
               cd.car_status = 'STOCK_IN',
               cd.last_updated_by        = p_user_id,
               cd.last_update_date       = Sysdate
         Where car_info_id = cur_ln.car_info_id;
       /* -- 更新合同状态信息  
        Update con_contract c
           Set c.contract_status  = 'INCEPT',
               c.last_updated_by  = p_user_id,
               c.last_update_date = Sysdate
         Where c.contract_id = cur_ln.contract_id;*/
        -- 更新移库行信息 
        Update con_move_cars_ln ln
           Set ln.is_moved_flag    = 'Y',
               ln.last_update_date = Sysdate,
               ln.last_updated_by  = p_user_id
         Where ln.line_id = cur_ln.line_id;
        If nvl(cur_ln.deposit_flag, 'N') = 'Y' Then
          ins_con_cashflow(cur_ln.contract_id, p_user_id);
        End If;
      End Loop;
    
      /* Elsif p_status = 'REJECT' Then
      For cur_con In (Select *
                        From con_move_cars_ln ln
                       Where hd_id = p_hd_id
                         And nvl(ln.early_redemp_payment, 0) > 0) Loop
      
        Select Max(cf.times)
          Into v_max_times
          From con_contract_cashflow cf, csh_write_off t
         Where cf.cashflow_id = t.cashflow_id
           And cf.write_off_flag = 'FULL'
           And cf.cf_item = 304
           And cf.contract_id = cur_con.contract_id;
      
        For cur_re In (Select t.write_off_id
                         From con_contract_cashflow cf, csh_write_off t
                        Where cf.cashflow_id = t.cashflow_id
                          And cf.times = v_max_times
                          And cf.write_off_flag = 'FULL'
                          And cf.cf_item = 304
                          And cf.contract_id = cur_con.contract_id) Loop
          v_reverse_write_off_id := '';
          --反冲   
          csh_write_off_pkg.reverse_write_off(p_reverse_write_off_id => v_reverse_write_off_id,
                                              p_write_off_id         => cur_re.write_off_id,
                                              p_reversed_date        => Sysdate,
                                              p_description          => '反冲',
                                              p_user_id              => p_user_id,
                                              p_from_csh_trx_flag    => Null);
        
        End Loop;
        --还原现金流                  
        restore_history_to_con(p_contract_id => cur_con.contract_id,
                               p_history_id  => cur_con.history_id,
                               p_user_id     => p_user_id);
      
      End Loop;*/
    End If;
  End con_move_cars_wfl_end;
  -- add by CLiyuan
  Procedure update_agent_id_and_other(p_ln_id          Number,
                                      p_after_id       Number,
                                      p_move_date      Date,
                                      p_remove_date    Date,
                                      p_phone          Varchar2,
                                      p_contact_person Varchar2,
                                      p_user_id        Number) Is
  Begin
    Update con_move_cars_ln l
       Set l.after_id         = p_after_id,
           l.move_date        = p_move_date,
           l.remove_date      = p_remove_date,
           l.phone            = p_phone,
           l.contact_person   = p_contact_person,
           l.last_update_date = Sysdate,
           l.last_updated_by  = p_user_id
     Where l.line_id = p_ln_id;
  Exception
    When Others Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => dbms_utility.format_error_backtrace || ' ' ||
                                                                                  Sqlerrm,
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'update_agent_id_and_other');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    
  End update_agent_id_and_other;

  Procedure cancel_apply_for_move(p_hd_id Number, p_user_id Number) Is
  Begin
    Update con_move_cars_hd h
       Set h.status           = 'CANCEL',
           h.last_update_date = Sysdate,
           h.last_updated_by  = p_user_id
     Where h.hd_id = p_hd_id;
    For i_cur In (Select * From con_move_cars_ln l Where l.hd_id = p_hd_id) Loop
      Update con_contract_df_car_info c
         Set c.car_status  = 'STOCK_IN',
             c.last_updated_by  = p_user_id,
             c.last_update_date = Sysdate
       Where c.car_info_id = i_cur.car_info_id;
    End Loop;
  Exception
    When Others Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => dbms_utility.format_error_backtrace || ' ' ||
                                                                                  Sqlerrm,
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'cancel_apply_for_move');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
  End cancel_apply_for_move;

  Procedure update_move_cars_for_wfl(p_ln_id        Number,
                                     p_deposit_flag Varchar2,
                                     p_user_id      Number) Is
  Begin
    Update con_move_cars_ln l
       Set l.deposit_flag     = p_deposit_flag,
           l.last_update_date = Sysdate,
           l.last_updated_by  = p_user_id
     Where l.line_id = p_ln_id;
  Exception
    When Others Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => dbms_utility.format_error_backtrace || ' ' ||
                                                                                  Sqlerrm,
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'update_move_cars_for_wfl');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
  End update_move_cars_for_wfl;

  Procedure check_deposit_flag(p_hd_id Number, p_user_id Number) Is
    e_save Exception;
  Begin
    For ln_cur In (Select *
                     From con_move_cars_ln ln
                    Where ln.hd_id = p_hd_id) Loop
      If ln_cur.deposit_flag Is Null Then
        Raise e_save;
      End If;
    End Loop;
  Exception
    When e_save Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => '请先保存字段：是否收取保证金',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'check_deposit_flag');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    When Others Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => dbms_utility.format_error_backtrace || ' ' ||
                                                                                  Sqlerrm,
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'check_deposit_flag');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
  End check_deposit_flag;

  Procedure df_permission_check(p_user_id Number) Is
    v_count Number;
    e_permission Exception;
  Begin
    Select Count(1)
      Into v_count
      From hls_bp_master hb
     Where hb.regulator = '01' -- 永久
       And hb.bp_code <> 'B00000010'
       And Exists (Select 1
              From sys_user su
             Where su.bp_id = hb.bp_id
               And su.user_id = p_user_id
               And su.bp_category = 'AGENT_DF');
    If v_count > 0 Then
      Raise e_permission;
    End If;
  
  Exception
    When e_permission Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => '请前往长久系统进行移库操作！',
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'df_permission_check');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
    When Others Then
      sys_raise_app_error_pkg.raise_sys_others_error(p_message                 => dbms_utility.format_error_backtrace || ' ' ||
                                                                                  Sqlerrm,
                                                     p_created_by              => p_user_id,
                                                     p_package_name            => 'con_df_car_confirm_pkg',
                                                     p_procedure_function_name => 'df_permission_check');
      raise_application_error(sys_raise_app_error_pkg.c_error_number,
                              sys_raise_app_error_pkg.g_err_line_id);
  End df_permission_check;
End con_df_car_confirm_pkg;
/
