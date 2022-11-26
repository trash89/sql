col Alloc form 999g999g999
col Free form 999g999g999
col PCT_REMP form 999.99
select 
substr(tablespace_name,1,15) "Tablespace" 
,round(sum(lalloc)/1024/1024,2) "Size" 
,round(sum(lfree)/1024/1024,2) "Free"
,round(max(lfree)/1024/1024,2) "Max"
,round((sum(lalloc)-sum(lfree))/sum(lalloc)*100,0) "% Full"
,count(lfree) "Frgt"
from
(select tablespace_name
,bytes lalloc
,0 lfree
from dba_data_files
union all
select tablespace_name 
, 0 lalloc
,bytes lfree
from dba_free_space
)
group by tablespace_name
order by 4
;
