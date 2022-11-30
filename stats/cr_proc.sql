rem Table STATS and procedure GET_STATS for getting the statistics about processes wich send and receive the messages to and from SQLNET
rem Autor Marius RAICU

drop table stats cascade constraints;
create table stats(db_name varchar2(20),process_name varchar2(20),date_time varchar2(20),stat_name varchar2(64),value number)
tablespace queues storage(initial 4K next 4K minextents 2 maxextents unlimited pctincrease 0);
 
create or replace procedure get_stats as
  cursor get_sesstat is select c.name as procname,e.name as statname,sum(a.value) as value
  from v$sesstat a,v$session b,v$bgprocess c,v$process d,v$statname e
  where (a.statistic# between 182 and 187) and e.statistic#=a.statistic# and a.value!=0 
        and d.addr=b.paddr and (b.paddr=c.paddr and c.paddr!='00')
  group by c.name,e.name;
  cursor get_total is select name,value from v$sysstat where name like '%Net%';
  v_date_time varchar2(20);
  v_global_name global_name.global_name%type;
begin
  select global_name into v_global_name from global_name;
  select to_char(sysdate,'dd/mm/rrrr hh24:mi:ss') into v_date_time from dual;
  insert into stats values(null,null,v_date_time,null,null);
  for rec in get_sesstat loop
         insert into stats values(v_global_name,rec.procname,v_date_time,rec.statname,rec.value);
  end loop;
  for rec1 in get_total loop
         insert into stats values(v_global_name,'TOTAL',v_date_time,rec1.name,rec1.value);
  end loop;
  commit;
end;
/

declare
  cursor get_jobs is select job from dba_jobs where what like '%get_stats;%';
  v_job number;
begin
  open get_jobs;
  fetch get_jobs into v_job;
  if get_jobs%notfound then
    close get_jobs;
    dbms_job.submit(v_job,'begin get_stats ;end;',sysdate,'sysdate+10/1440'); 
    commit;
  else
    close get_jobs;
    dbms_job.remove(v_job);
    commit;
    dbms_job.submit(v_job,'begin get_stats ;end;',sysdate,'sysdate+10/1440'); 
    commit;
  end if;
end;
/

