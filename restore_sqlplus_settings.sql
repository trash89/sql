-------------------------------------------------------------------------------
--
-- Script:	restore_sqlplus_settings.sql
-- Purpose:	to reset sqlplus settings
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------

set termout off
@/tmp/sqlplus_settings
clear breaks
clear columns
clear computes
set termout on
