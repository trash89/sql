grant execute on sys.dbms_shared_pool to system;
grant select on dba_sequences to system;
grant select on dba_sequences to system;

create or replace
procedure system.pin_on_startup is
  procedure try_to_keep(p_name varchar2, p_type varchar2) is
  begin
    sys.dbms_shared_pool.keep(p_name,p_type);
  exception when others then null;
  end;
begin
  for i in ( select sequence_owner || '.' || sequence_name seq
             from sys.dba_sequences
             where cache_size > 0 ) loop
    sys.dbms_shared_pool.keep(i.seq, 'Q');
  end loop;
  try_to_keep('SYS.DBMS_APPLICATION_INFO','P');
  try_to_keep('SYS.DBMS_LOCK','P');
  try_to_keep('SYS.DBMS_OUTPUT','P');
  try_to_keep('SYS.DBMS_PIPE','P');
  try_to_keep('SYS.DBMS_SESSION','P');
  try_to_keep('SYS.DBMS_SHARED_POOL','P');
  try_to_keep('SYS.DBMS_SQL','P');
  try_to_keep('SYS.DBMS_STANDARD','P');
  try_to_keep('SYS.DBMS_SYS_SQL','P');
  try_to_keep('SYS.DBMS_UTILITY','P');
  try_to_keep('SYS.PBREAK','P');
  try_to_keep('SYS.PBRPH','P');
  try_to_keep('SYS.PBSDE','P');
  try_to_keep('SYS.PBUTL','P');
  try_to_keep('SYS.PLITBLM','P');
  try_to_keep('SYS.STANDARD','P');
  try_to_keep('SYS.SYS_STUB_FOR_PURITY_ANALYSIS','P');
  try_to_keep('SYS.UTL_FILE','P');
  try_to_keep('SYS.DBMS_ALERT','P');
  try_to_keep('SYS.DBMS_DESCRIBE','P');
  try_to_keep('SYS.DBMS_JOB','P');
  try_to_keep('SYS.DBMS_AQ','P');   --- for AQ
  try_to_keep('SYS.DBMS_AQADM','P');--- for AQADM
  try_to_keep('SYS.DBMS_REPCAT','P');--- for replication
  try_to_keep('SYS.DBMS_RANDOM','P');
  try_to_keep('SYS.DBMS_SQL','P');
  try_to_keep('SYS.DIANA','P');
  try_to_keep('SYS.DIUTIL','P');
end;
/

create or replace
trigger system.dbstart_pin_sequences
after startup on database
begin
  execute immediate 'begin system.pin_on_startup; end;';
exception when others then null;
end;
/

create or replace
procedure system.unload_sequences_from_sga is
  c integer;
begin
  for i in ( select sequence_owner||'.'||sequence_name ||'1' sortkey,
                    'alter sequence ' || sequence_owner || '.' || sequence_name || ' nocache' ddl
             from sys.dba_sequences
             where cache_size > 0
             union all
             select sequence_owner||'.'||sequence_name ||'2' sortkey,
                    'alter sequence ' || sequence_owner || '.' || sequence_name || ' cache '||cache_size
             from sys.dba_sequences
             where cache_size > 0
             order by 1 ) loop
   c := dbms_sql.open_cursor;
   dbms_sql.parse(c,i.ddl,dbms_sql.native);
   dbms_sql.close_cursor(c);
  end loop;
end;
/


create or replace
trigger system.dbshut_unload_sequences
before shutdown on database
begin
  execute immediate 'begin system.unload_sequences_from_sga; end;';
exception when others then null;
end;
/

