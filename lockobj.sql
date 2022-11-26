
set lines 130 pages 22 trims on trim on
column inst_id format 9 head 'I'

select /*+ rule */
nvl(inst_id,1) inst_id
,substr(a.owner,1,15) "Owner"
,substr(a.object_name,1,30) "Name"
,substr(a.object_type,1,10) "Type"
,substr(b.session_id,1,5) "SID"
,substr(b.oracle_username,1,10) "User"
,decode(b.locked_mode
	,1,'Null'
	,2,'Row-S'
	,3,'Row-X'
	,4,'Share'
	,5,'S/Row-X'
	,6,'Exclu') "Type"
from
    dba_objects a,gv$locked_object b
where
    a.object_id=b.object_id;

set lines 90 pages 22

