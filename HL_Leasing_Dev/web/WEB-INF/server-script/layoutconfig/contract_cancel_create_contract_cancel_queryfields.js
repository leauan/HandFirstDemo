var add_datafilters=[
{
	name:'bp_id_agent_level1',
	expression : "t1.bp_id_agent_level1 = decode((select su.bp_category from sys_user su where su.user_id =${/session/@user_id}),'AGENT',(select su.bp_id from sys_user su where su.user_id =${/session/@user_id}),'EMPLOYEE',t1.bp_id_agent_level1)"
},
{
	name:'contract_status',
	expression : "t1.contract_status in ('NEW','SIGN') and t1.lease_channel='00'"
},
{
	name:'cancel_status',
	expression : "nvl(t1.cancel_status,'NEW') not in ('APPROVING','APPROVED')"
}
];

add_datafilter();


