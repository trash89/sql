create or replace package dbms_application_info as

  procedure read_client_info(client_info out varchar2);
  procedure read_module(module_name out varchar2,action_name out varchar2);
  procedure set_action(action_name in varchar2);
  procedure set_client_info(client_info in varchar2);
  procedure set_module(module_name in varchar2,action_name in varchar2);

  procedure set_session_longops(rindex in out binary_integer,slno in out binary_integer,op_name in varchar2,target in binary_integer,
      context in binary_integer,sofar in number,totalwork in number,target_desc in varchar2,units in varchar2);
  set_session_longops_nohint constant pls_integer := -1;

  type v_module is table of varchar2(48);
  g_module v_module; --stack
  g_level integer; --stack pointer
  g_action varchar2(32);

end dbms_application_info;
/

create or replace package body dbms_application_info as

  procedure read_client_info(client_info out varchar2) is
  begin
    sys.dbms_application_info.read_client_info(client_info);
  end read_client_info;

  procedure read_module(module_name out varchar2,action_name out varchar2) is
  begin
    sys.dbms_application_info.read_module(module_name,action_name);
  end read_module;

  procedure set_action(action_name in varchar2) is
  begin
    sys.dbms_application_info.set_action(action_name);
  end set_action;

  procedure set_client_info(client_info in varchar2) is
  begin
    sys.dbms_application_info.set_client_info(client_info);
  end set_client_info;

  procedure set_session_longops(rindex in out binary_integer,slno in out binary_integer,op_name in varchar2,target in binary_integer,
      context in binary_integer,sofar in number,totalwork in number,target_desc in varchar2,units in varchar2) is
  begin
    sys.dbms_application_info.set_session_longops(rindex,slno,op_name,target,context,sofar,totalwork,target_desc,units);
  end set_session_longops;




  procedure set_module(module_name in varchar2,action_name in varchar2) is
  begin
    if action_name = ’Enter’ then
      g_level := g_level+1;
      if g_level > g_module.last then
        g_module.extend;
      end if;
      g_module(g_level) := module_name;
      sys.dbms_application_info.set_module(module_name,’Called by ’||g_module(g_level-1));
    elsif action_name = ’Exit’ then
      g_level := g_level-1;
      sys.dbms_application_info.set_module(g_module(g_level),’Returned from ’||module_name);
    else
      sys.dbms_application_info.set_module(module_name,action_name);
    end if;
  end;



begin
  g_level := 1;
  sys.dbms_application_info.read_module(g_module(g_level),g_action);
end dbms_application_info;
/

