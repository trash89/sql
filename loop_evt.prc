--
--      Script:   loop_evt.prc
--      Author:   J P Lewis
--      Dated:    22-Jan-1999
--      Purpose:  Code for procedure system_event
--

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