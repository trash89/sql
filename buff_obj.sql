rem
rem     Script:         buff_obj.sql
rem     Author:         J.P.Lewis
rem     Dated:          25-Oct-1998
rem     Purpose:        List blocks per object in buffer, by buffer pool
rem
rem     Notes:
rem     This has to be run by SYS because the 'working data set' is 
rem     only present as an X$ internal, and the column of the buffer
rem     header that we need is not exposed in the v$bh view
rem
rem     Objects are only reported if they have a signficant number of
rem     blocks in the buffer.  The code here is set to show object
rem     which have 5 times the number of latches active in the
rem     working set with most latches.
rem
rem     There is one oddity - the obj number stored in the x$bh is
rem     the dataobj#, not the obj$# - so some objects (e.g. tables in
rem     clusters) will generate spurious figures where the count is
rem     multiplied up by the number of objects in the data object.
rem
rem     Objects owned by SYS have been omitted (owner# > 0)
rem
rem     The various X$ tables and columns are undocumented, so the code
rem     is written on a best-guess basis, but the results seems to be 
rem     as expected.
rem

clear breaks
clear columns

compute sum of blocks on report

column pool_name format a9
column object format a24
column sub_name format a24
column blocks format 999,999

break on pool_name

set pagesize 60
set newpage 0

spool buff_obj

select
        /*+ ordered */
        bp.name                         pool_name,
        ob.name                         object, 
        ob.subname                      sub_name, 
        sum(ct)                         blocks
from
        (
        select
                set_ds,
                obj,
                count(*) ct
        from
                x$bh
        group by
                set_ds, 
                obj
        having count(*)/5 > (
                        select max(set_count) 
                        from v$buffer_pool
                        )
        )                       bh,
        obj$                    ob,
        x$kcbwds                ws,
        v$buffer_pool           bp
where
        ob.dataobj# = bh.obj
and     ob.owner# > 0
and     bh.set_ds = ws.addr
and     ws.set_id between bp.lo_setid and bp.hi_setid
and     bp.buffers != 0         --  Eliminate any pools not in use
group by
        bp.name,
        ob.name,
        ob.subname
order by
        bp.name,
        ob.name,
        ob.subname
;

spool off
