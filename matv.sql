--
--  Script    : matv.sql
--  Purpose   : show materialized views FROM dba_mviews
--  Tested on : 10g,11g,12c,19c,23c
--
@save_sqp_set

set lines 158 pages 50

undef own
accept own char prompt 'Owner?(%)      : ' default ''

col mv                 for a60        head 'Materialized view'
col compile_state      for a19        head 'Compile State'
col staleness          for a19        head 'Staleness'
col refresh_mode       for a9         head 'RefreMode'
col refresh_method     for a8         head 'RefrMeth'
col fast_refreshable   for a18        head 'Fast refresh'
col updatable          for a3         head 'Upd'
col rewrite_enabled    for a4         head 'Rewr'
col lastr              for a10        head 'LastRefr'
ttitle left 'dba_mviews'
SELECT 
     owner||'.'||mview_name                     as mv
    ,compile_state 
    ,staleness
    ,refresh_mode
    ,refresh_method
    ,fast_refreshable    
    ,updatable
    ,rewrite_enabled
    ,to_char(last_refresh_date,'dd/mm/rrrr')    as lastr
FROM 
    dba_mviews
WHERE
   owner LIKE upper('%&&own%')
ORDER BY 
     owner
    ,mview_name
;

undef tab
undef own

@rest_sqp_set
