column owner_name format a15
column object_name format a25
column possible_disk_reads format 999999999999
select /*+ ordered use_hash(d) use_hash(c) */
o.kglnaown as owner_name,
o.kglnaobj as object_name,
sum(c.kglobt13) possible_disk_reads
from
x$kglob o,
x$kgldp d,
x$kglcursor c
where
c.inst_id = userenv('Instance') and
d.inst_id = userenv('Instance') and
o.inst_id = userenv('Instance') and
o.kglhdnsp = 1 and
o.kglobtyp = 2 and
d.kglrfhdl = o.kglhdadr and
c.kglhdadr = d.kglhdadr and
o.kglnaown not in ('SYS','SYSTEM') --- added MR
group by
o.kglnaown,
o.kglnaobj
order by
sum(c.kglobt13)
--having sum(c.kglobt13)>=100 -- added MR
;
clear columns

