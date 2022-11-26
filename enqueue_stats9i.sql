-------------------------------------------------------------------------------
--
-- Script:	enqueue_stats.sql
-- Purpose:	to display enqueue statistics
-- For:		9i
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
-- Modified :   Marius RAICU
--
-------------------------------------------------------------------------------
@save_sqlplus_settings

select
  q.ksqsttyp type,
  q.ksqstsgt gets,
  q.ksqstwat waits
from
  sys.x_$ksqst  q
where
  q.inst_id = userenv('Instance') and
  q.ksqstsgt > 0
/

@restore_sqlplus_settings
