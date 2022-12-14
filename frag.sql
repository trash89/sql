--
--  Script : frag.sql
--  Author : Unknown
--  Modif  : Marius RAICU
--  Purpose: Report contiguous free space 
--  Tested : 9i
--  To do  : test and validate on earlier versions of Oracle
----------------------------------------------------------------------------

@save_sqlplus_settings

create table SPACE_TEMP(   
   TABLESPACE_NAME        CHAR(30),   
   CONTIGUOUS_BYTES       NUMBER
);
declare   
    cursor query is 
      select /*+ rule */* from dba_free_space  
      where (tablespace_name not like 'RBS%' and tablespace_name not like 'UNDO%') 
      order by tablespace_name, block_id;   
    this_row        query%rowtype;   
    previous_row    query%rowtype;   
  total           number;   
begin   
    open query;   
    fetch query into this_row;   
    previous_row := this_row;   
    total := previous_row.bytes;   
    loop   
       fetch query into this_row;   
       exit when query%notfound;   
       if this_row.block_id = previous_row.block_id + previous_row.blocks then   
          total := total + this_row.bytes;   
          insert into SPACE_TEMP (tablespace_name) values (previous_row.tablespace_name);   
       else   
          insert into SPACE_TEMP values (previous_row.tablespace_name,total);   
          total := this_row.bytes;   
       end if;   
       previous_row := this_row;   
    end loop;   
    insert into SPACE_TEMP values (previous_row.tablespace_name,total);   
end;   
/   
set pagesize 60   
set newpage 0   
set echo off   
rem ttitle center 'Contiguous Extents Report'  skip 3   
rem break on "TABLESPACE NAME" skip page duplicate   
spool contig_free_space.lst   
rem   
column "CONTIGUOUS BYTES"       format 999,999,999   
column "COUNT"                  format 999   
column "TOTAL BYTES"            format 999,999,999   
column "TODAY"   noprint new_value new_today format a1   
rem   
select TABLESPACE_NAME  "TABLESPACE NAME",   
       CONTIGUOUS_BYTES "CONTIGUOUS BYTES"   
from SPACE_TEMP   
where CONTIGUOUS_BYTES is not null
order by TABLESPACE_NAME, CONTIGUOUS_BYTES desc;   
     
select tablespace_name, count(*) "# OF EXTENTS",   
       sum(contiguous_bytes) "TOTAL BYTES"    
from space_temp   
group by tablespace_name;   
spool off   
drop table SPACE_TEMP;   
ttitle off
clear columns
clear breaks

@restore_sqlplus_settings

