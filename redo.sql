
@save_sqlplus_settings

col rsize for 999999.99 head 'RedoSize|(Mb)'
col ft head 'Fist Time'
col inst_id for 99 head 'I'
col group# for 99 head 'G#'
col thread# for 99 head 'T#'
select 
    nvl(inst_id,1) inst_id,group#,thread#,min(to_char(first_time,'mm/dd/yy hh24:mi:ss')) ft,min(bytes/1024/1024) rsize 
from 
    gv$log 
group by 
    nvl(inst_id,1),group#,thread#
;

SELECT
        nvl(cp.inst_id,1) inst,
        le.leseq                        CURRENT_LOG_SEQUENCE#,
        100*cp.cpodr_bno/LE.lesiz       PERCENTAGE_FULL
from
        x$kcccp cp,x$kccle le
WHERE
        LE.leseq =CP.cpodr_seq
;

@restore_sqlplus_settings

