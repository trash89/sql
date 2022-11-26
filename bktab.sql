------------------------------------------------------------
--  Breakdown IO by table
--  Author: Steve Adams, K. Gopalakhrishnan
--  For: Oracle 8i,9i
------------------------------------------------------------
@save_sqlplus_settings

set lines 120 pages 80
column owner_name format a15
column table_name format a30

select /*+ ordered use_hash(d) use_hash(c) */
                  o.kglnaown  owner_name,
                  o.kglnaobj  table_name,
                  sum(c.kglobt13)  possible_disk_reads
                from
                  sys.x_$kglob  o,
                  sys.x_$kgldp  d,
                  sys.x_$kglcursor  c
                where
                  c.inst_id = userenv('Instance') and
                  d.inst_id = userenv('Instance') and
                  o.inst_id = userenv('Instance') and
                  o.kglhdnsp = 1 and
                  o.kglobtyp = 2 and
                  d.kglrfhdl = o.kglhdadr and
                  c.kglhdadr = d.kglhdadr 
                  and o.kglnaown not in ('SYS','SYSTEM') --- added MR
                group by
                  o.kglnaown,
                  o.kglnaobj
                order by
                  sum(c.kglobt13);

@restore_sqlplus_settings

