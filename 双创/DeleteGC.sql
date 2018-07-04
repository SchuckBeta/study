
DELIMITER $$
CREATE DEFINER = CURRENT_USER FUNCTION `DeleteGC`(c varchar(255))
 RETURNS varchar(255)  
BEGIN
	DECLARE a varchar(255);
	DECLARE b varchar(255);
	set a= (SELECT proc_ins_id FROM g_contest WHERE competition_number=c);
	set b= (SELECT id FROM g_contest WHERE competition_number=c);

-- a='4bfe73e548314d2b89dcc37b9acb222d'; --
-- b='95ae451d5b104eb38c5f7fc380c641e9'; --


	DELETE FROM act_hi_taskinst WHERE PROC_INST_ID_=a;
	DELETE FROM act_hi_varinst WHERE PROC_INST_ID_=a;
	DELETE FROM act_ru_variable WHERE PROC_INST_ID_=a;
	DELETE FROM act_ru_identitylink where PROC_INST_ID_=a;
	DELETE FROM act_ru_identitylink where TASK_ID_ in
		(select ID_ FROM act_ru_task where PROC_INST_ID_=a);
		
	delete from act_ru_task where PROC_INST_ID_=a;	
	DELETE FROM act_ru_execution WHERE PROC_INST_ID_=a and parent_id_ is not null;
	DELETE FROM act_ru_execution WHERE PROC_INST_ID_=a;

	
	update team_user_history t
		inner join g_contest g
		on g.id=t.pro_id
		set t.del_flag='1'
		where g.id=b; 
		
	
   DELETE FROM g_contest where competition_number=c;
    return a;

END $$
DELIMITER ;
