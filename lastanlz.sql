@save_sqlplus_settings

select 
    owner,trunc(last_analyzed),count(*) 
from 
    dba_all_tables 
where 
    owner not in ('SYS','SYSTEM') 
group by 
    owner,trunc(last_analyzed)
order by owner;

@restore_sqlplus_settings


