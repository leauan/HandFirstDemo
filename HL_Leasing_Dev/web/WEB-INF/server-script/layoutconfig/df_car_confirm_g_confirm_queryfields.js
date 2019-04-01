var override_queryfields = [
	{
		name : 'item_frame_number',
		queryexpression : "t1.item_frame_number like '%'|| ${@item_frame_number} || '%'"
	}
];
override();
var add_datafilters = [ {
	name : 'owner_user_id',
	expression : "exists (select 1 from sys_user su where (su.bp_category = 'EMPLOYEE' or ( t1.bp_id_tenant=su.bp_id AND su.bp_category = 'AGENT_DF') ) and su.user_id = ${/session/@user_id})"
} ]

add_datafilter();

