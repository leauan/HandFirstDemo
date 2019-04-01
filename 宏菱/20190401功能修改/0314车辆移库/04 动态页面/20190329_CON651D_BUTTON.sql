WHENEVER SQLERROR EXIT FAILURE ROLLBACK;
WHENEVER OSERROR  EXIT FAILURE ROLLBACK;

spool 20190329_con651d_button.log

set feedback off
set define off


BEGIN
SYS_LOAD_HLS_DOC_LAYOUT_PKG.delete_layout_button(p_function_code=>'CON651D');
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'EXIT',P_PROMPT=>'退出',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>10,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'Y',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'SAVE',P_PROMPT=>'保存',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>20,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'Y',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'SAVE_EXIT',P_PROMPT=>'保存并退出',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>30,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'DOC_FLOW',P_PROMPT=>'单据流',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>40,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'SUBMIT_APPROVAL',P_PROMPT=>'提交审批',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>50,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'Y',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'QUOTE',P_PROMPT=>'报价',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>60,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'PRINT',P_PROMPT=>'打印',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>70,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'QUERY',P_PROMPT=>'查询',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>80,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'RESET',P_PROMPT=>'重置',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>85,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'UPLOAD',P_PROMPT=>'附件上传',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'Y',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>90,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>null,P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'USER_BUTTON1',P_PROMPT=>'批量填写',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'N',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>200,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'Y',P_ACTION_AFTER_BUTTON=>'EXIT',P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'USER_BUTTON2',P_PROMPT=>'取消申请',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'N',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>210,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'Y',P_ACTION_AFTER_BUTTON=>'EXIT',P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'USER_BUTTON3',P_PROMPT=>'用户按钮3',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'N',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>220,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>'EXIT',P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'USER_BUTTON4',P_PROMPT=>'用户按钮4',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'N',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>230,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>'EXIT',P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'USER_BUTTON5',P_PROMPT=>'用户按钮5',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'N',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>240,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>'EXIT',P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'USER_BUTTON6',P_PROMPT=>'用户按钮6',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'N',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>250,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>'EXIT',P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'USER_BUTTON7',P_PROMPT=>'用户按钮7',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'N',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>260,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>'EXIT',P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'USER_BUTTON8',P_PROMPT=>'用户按钮8',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'N',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>270,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>'EXIT',P_USER_ID=>1);
SYS_LOAD_HLS_DOC_LAYOUT_PKG.load_layout_button(P_FUNCTION_CODE=>'CON651D',P_BUTTON_CODE=>'USER_BUTTON9',P_PROMPT=>'用户按钮9',P_SAVE_DATA_FIRST=>'N',P_SYSTEM_FLAG=>'N',P_DISPLAY_FLAG=>'Y',P_DISPLAY_ORDER=>280,P_JAVASCRIPT=>null,P_ENABLED_FLAG=>'N',P_ACTION_AFTER_BUTTON=>'EXIT',P_USER_ID=>1);
END;
/
commit;

set feedback on
set define on

spool off

exit
