var add_datafilters = [ {
	name : 'bp_id',
	expression : "exists (select 1 from sys_user su where (su.bp_category = 'EMPLOYEE' or ( t1.bp_id=su.bp_id AND su.bp_category = 'AGENT_DF')  ) and su.user_id = ${/session/@user_id})"
},
{
	name : 'confirm_flag',
	expression : "nvl(t1.confirm_flag,'N') IN ('J','R','N')"
}]

add_datafilter();

