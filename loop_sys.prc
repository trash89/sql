--
--    Script:     loop_sys.prc
--    Author:     J P Lewis
--    Dated:      22-Jan-1999
--    Purpose:    Code for procedure system_stats
--

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