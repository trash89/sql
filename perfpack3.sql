rem
rem   Script:     perfpack3.sql
rem   Author:     J P Lewis
rem   Dated:      22-Jan-1999
rem   Purpose:    Monitor several stats with a single call
rem
rem   Usage:
rem         execute performance_snapshot3.to_file(
rem              i_directory => {dir},
rem              i_time_lapse => {minutes},
rem              i_cycles => {count},
rem              i_want_sys_events => {TRUE/FALSE}
rem              i_want_file_stats => {TRUE/FALSE}
rem              i_want_session_io => {TRUE/FALSE}
rem              i_want_sys_stats  => {TRUE/FALSE}
rem              i_want_roll_stats => {TRUE/FALSE}
rem              i_want_wait_stats => {TRUE/FALSE}
rem              i_want_file_waits => {TRUE/FALSE}
rem         );
rem
rem         execute performance_snapshot3.to_file(
rem              i_directory => '/tmp/',
rem              i_time_lapse => 5,
rem              i_cycles => 12,
rem              i_want_sys_events => TRUE
rem         );
rem
rem   Notes:
rem         The directory where the files will be written HAS to be
rem         listed under utl_file_dir in the init.ora file.
rem
rem         The default action is to record one snapshot of 10 minutes
rem         and produce NO stats whatsoever.
rem
rem         Useful only for a single instance, but could be modified
rem         by changes to cursor c1 for multi-instance.
rem
rem         The package has to be created by SYS mainly because of 
rem         the references to the x$ objects in some procedures
rem

create or replace package performance_snapshot3 as

procedure to_file (
      i_directory             in     varchar2, 
      i_time_lapse            in     number      default 10,
      i_cycles                in     number      default 1,
      i_want_sys_events       in     boolean     default FALSE,
      i_want_file_stats       in     boolean     default FALSE,
      i_want_session_io       in     boolean     default FALSE,
      i_want_sys_stats        in     boolean     default FALSE,
      i_want_roll_stats       in     boolean     default FALSE,
      i_want_wait_stats       in     boolean     default FALSE,
      i_want_file_waits       in     boolean     default FALSE
);

end performance_snapshot3;
/

create or replace package body performance_snapshot3 as

procedure to_file (
      i_directory            in      varchar2,
      i_time_lapse           in      number      default 10,
      i_cycles               in      number      default 1,
      i_want_sys_events      in      boolean     default FALSE,
      i_want_file_stats      in      boolean     default FALSE,
      i_want_session_io      in      boolean     default FALSE,
      i_want_sys_stats       in      boolean     default FALSE,
      i_want_roll_stats      in      boolean     default FALSE,
      i_want_wait_stats      in      boolean     default FALSE,
      i_want_file_waits      in      boolean     default FALSE
) is

vcTimeStamp      varchar2(10);

cursor c_system_event is
select 
      d.indx            indx,    
      d.kslednam        event, 
      s.ksleswts        total_waits, 
      s.kslestim        time_waited
from
      x$kslei s,
      x$ksled d 
where    
      s.indx = d.indx
order by
      d.indx
;

type w_type is table of c_system_event%rowtype index by binary_integer;
w_list w_type;

cursor c_system_stat is
      select
            statistic#,
            name,
            value
      from
            v$sysstat
      order by
            statistic#;

type s_type is table of c_system_stat%rowtype index by binary_integer;
s_list s_type;

procedure system_events (
      i_directory       in     varchar2,
      i_TimeStamp       in     varchar2,
      i_current_loop    in     number
) is

      fOutput           utl_file.file_type;

begin

      if (i_current_loop = 0) then

            for r in c_system_event loop
                  w_list(r.indx).event := r.event;
                  w_list(r.indx).total_waits := r.total_waits;
                  w_list(r.indx).time_waited := r.time_waited;
            end loop;

      else
      

            fOutput :=  utl_file.fopen(
                              i_directory,
                              'system_events.'||i_Timestamp,
                              'w'
                        );
      

            utl_file.put_line(fOutput,rpad('-',46,'-'));
            utl_file.put_line(
                        fOutput,
                        'System Events in ' || 
                        to_char(i_time_lapse) ||
                        ' minutes to ' ||
                        to_char(sysdate,'dd-Mon hh24:mi:ss') 
            );
            utl_file.put_line(fOutput,rpad('-',46,'-'));
      

      
            utl_file.put_line(
                        fOutput,
                        rpad('Event',43) ||
                        lpad('Waits',12) ||
                        lpad('Csec',12) ||
                        lpad('Avg Csec',12)
            );
      

            utl_file.put_line(
                        fOutput,
                        rpad('-----',43) ||
                        lpad('-----',12) ||
                        lpad('----',12) ||
                        lpad('--------',12)
            );
      

            for r in c_system_event loop

                  if (not w_list.exists(r.indx)) then
                        w_list(r.indx).total_waits := 0;
                        w_list(r.indx).time_waited := 0;
                  end if;
      

                  if (
                           (w_list(r.indx).total_waits != r.total_waits)
                        or (w_list(r.indx).time_waited != r.time_waited)
                  ) then
                        utl_file.put(fOutput,rpad(substr(r.event,1,43),43));
                        utl_file.put(
                              fOutput,
                              to_char( 
                                    r.total_waits - w_list(r.indx).total_waits,
                                    '999,999,990'
                              )
                        );
                        utl_file.put(
                              fOutput,
                              to_char( 
                                    r.time_waited - w_list(r.indx).time_waited,
                                    '999,999,990'
                              )
                        );
                        utl_file.put_line(
                              fOutput,
                              to_char( 
                                    (      r.time_waited - 
                                           w_list(r.indx).time_waited
                                    ) /
                                    greatest(
                                          r.total_waits - 
                                          w_list(r.indx).total_waits, 1
                                    ),
                                    '999,999.990'
                              )
                        );
      

                  end if;
      

                  w_list(r.indx).event := r.event;
                  w_list(r.indx).total_waits := r.total_waits;
                  w_list(r.indx).time_waited := r.time_waited;

            end loop;

            utl_file.fclose(fOutput);
      

      end if;

end system_events;

procedure system_stats (
      i_directory       in     varchar2,
      i_TimeStamp       in     varchar2,
      i_current_loop    in     number
) is

      fOutput           utl_file.file_type;

begin

      if (i_current_loop = 0) then

            for r in c_system_stat loop
                  s_list(r.statistic#).name := r.name;
                  s_list(r.statistic#).value := r.value;
            end loop;

      else

            fOutput := utl_file.fopen(
                  i_directory,
                  'system_stats.'||i_Timestamp,
                  'w'
            );

            utl_file.put_line(fOutput,rpad('-',45,'-'));

            utl_file.put_line(
                        fOutput,
                        'System Stats in ' ||
                        to_char(i_time_lapse) ||
                        ' minutes to ' ||
                        to_char(sysdate,'dd-Mon hh24:mi:ss')
            );
            utl_file.put_line(fOutput,rpad('-',45,'-'));

            utl_file.put_line(fOutput, rpad('Name',64) || lpad('Value',15));
            utl_file.put_line(fOutput, rpad('----',64) || lpad('-----',15));

            for r in c_system_stat loop

                  if ((s_list(r.statistic#).value != r.value)) then
                        utl_file.put(
                              fOutput,
                              rpad(s_list(r.statistic#).name,64)
                        );
                        utl_file.put_line(
                              fOutput,
                              to_char(
                                    r.value - s_list(r.statistic#).value,
                                    '99,999,999,990')
                        );
                  end if;

                  s_list(r.statistic#).name := r.name;
                  s_list(r.statistic#).value := r.value;

            end loop;

            utl_file.fclose(fOutput);

      end if;

end system_stats;

begin

      for v_cycles_done in 0..i_cycles loop

            select
                  to_char(sysdate,'mmddhh24miss') 
            into
                  vcTimestamp 
            from
                  dual;

            if i_want_sys_events then
                  system_events(i_directory,vcTimeStamp,v_cycles_done);
            end if;

            if i_want_sys_stats then
                  system_stats(i_directory,vcTimeStamp,v_cycles_done);
            end if;

            if v_cycles_done != i_cycles then
                  dbms_lock.sleep(60 * i_time_lapse);
            end if;

      end loop;

exception   -- to put out a warning about files
      when
               utl_file.invalid_path
            or utl_file.invalid_mode
            or utl_file.invalid_filehandle
            or utl_file.invalid_operation
            or utl_file.read_error
            or utl_file.write_error
            or utl_file.internal_error
        then
                dbms_output.put_line('File handling problem');
                dbms_output.put_line(sqlcode);
        when others then 
                raise;

end to_file;

end performance_snapshot3;
/

grant execute on performance_snapshot3 to public;
drop public synonym performance_snapshot3;
create public synonym performance_snapshot3 for sys.performance_snapshot3;

