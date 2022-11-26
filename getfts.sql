
@save_sqlplus_settings

select  distinct
    a.sid,
    c.owner,
    c.segment_name
from 
    sys.v_$session_wait a,
    sys.v_$datafile b,
    sys.dba_extents c
where 
    a.p1 = b.file# and
    b.file# = c.file_id and
    a.p2 between c.block_id and (c.block_id + c.blocks) and
    a.event = 'db file scattered read';

@restore_sqlplus_settings


