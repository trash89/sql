-------------------------------------------------------------------------------
--
-- Script:	schema_objects.sql
-- Purpose:	to count the objects of each type owned by each schema
--
-- Copyright:	(c) 2000 Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

column name format a13 trunc heading SCHEMA
column cl format 9999 heading CLSTR
column ta format 9999 heading TABLE
column ix format 9999 heading INDEX
column se format 9999 heading SEQNC
column tr format 9999 heading TRIGR
column fn format 9999 heading FUNCT
column pr format 9999 heading PROCD
column pa format 9999 heading PACKG
column vi format 9999 heading VIEWS
column sy format 9999 heading SYNYM
column ot format 9999 heading OTHER
break on report
compute sum of cl ta ix se tr fn pr pa vi sy ot on report

select
  u.name,
  sum(decode(o.type#, 3, objs))  cl,
  sum(decode(o.type#, 2, objs))  ta,
  sum(decode(o.type#, 1, objs))  ix,
  sum(decode(o.type#, 6, objs))  se,
  sum(decode(o.type#, 12, objs)) tr,
  sum(decode(o.type#, 8, objs))  fn,
  sum(decode(o.type#, 7, objs))  pr,
  sum(decode(o.type#, 9, objs))  pa,
  sum(decode(o.type#, 4, objs))  vi,
  sum(decode(o.type#, 5, objs))  sy,
  sum(decode(o.type#, 1,0, 2,0, 3,0, 4,0, 5,0, 6,0, 7,0, 8,0, 9,0, 12,0, objs))  ot
from
(select owner#, type#, count(*) objs from sys.obj$ group by owner#, type#)  o,
sys.user$  u
where
  u.user# = o.owner#
group by
  u.name
order by
  decode(u.name, 'SYS', 1, 'SYSTEM', 2, 'PUBLIC', 3, 4),
  u.name
/

@restore_sqlplus_settings
