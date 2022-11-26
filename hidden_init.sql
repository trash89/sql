@save_sqlplus_settings
set lines 250 pages 200
column name format a50
column value format a20
column deflt for a5
column type for a7
column description for a70
select a.ksppinm name,b.ksppstvl value,b.ksppstdf deflt,decode(a.ksppity, 1,'boolean', 2,'string', 3,'number', 4,'file', a.ksppity) type,a.ksppdesc description
from sys.x$ksppi a,sys.x$ksppcv b
where a.indx = b.indx and a.ksppinm like '\_%' escape '\'
order by name;

set lines 132 pages 22
@restore_sqlplus_settings
