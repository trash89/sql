
create or replace package body oid_ldap_pkg as


  procedure trace(p_msg in varchar2) is
   c_date varchar2(50):=to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - oid_ldap_pkg - ';
  begin
    dbms_output.put_line(substr(c_date||' '||p_msg,1,255));
    if oid_ldap_debug.trace_to_file=true then
      sys.dbms_system.ksdwrt(sys.dbms_system.alert_file,c_date||p_msg);
    end if;
  end trace;

  procedure print_error(p_func_name in varchar2,p_ldap_func_name in varchar2,p_retval in pls_integer,p_sqlerrm in varchar2) is
  begin
    if oid_ldap_debug.active_trace=true then 
      trace(p_func_name||': '||p_ldap_func_name||' failed. Retval= '||to_char(p_retval)||' SQLERRM='||p_sqlerrm);
    else 
      DBMS_OUTPUT.PUT_LINE(substr(to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - oid_ldap_pkg - '||' '||p_func_name||': '||p_ldap_func_name||' failed. Retval= '||to_char(p_retval),1,255));
      DBMS_OUTPUT.PUT_LINE(' SQLERRM='||p_sqlerrm);
    end if;
  end print_error;



  function get_ldap return varchar2 is
  begin
    return ldap_host||':'||ldap_port;
  end get_ldap;                

  function get_default_realm return varchar2 is
    l_retval pls_integer:=-1;
    subscriber_handle DBMS_LDAP_UTL.HANDLE;
    sub_type PLS_INTEGER;
    subscriber_id VARCHAR2(2000);
    subscriber_dn VARCHAR2(32000):=null;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function get_default_realm() ...');
    end if; 

    sub_type := DBMS_LDAP_UTL.TYPE_DEFAULT;
    subscriber_id := NULL;

    declare
    begin 
      l_retval := DBMS_LDAP_UTL.create_subscriber_handle(subscriber_handle,sub_type,subscriber_id);
      if oid_ldap_debug.active_trace=true then 
        trace('__create_subscriber_handle Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('get_default_realm','DBMS_LDAP_UTL.create_subscriber_handle()',l_retval,sqlerrm);
        return null;
      end;   
    end;
    if l_retval!=DBMS_LDAP_UTL.SUCCESS THEN 
      print_error('get_default_realm','DBMS_LDAP_UTL.create_subscriber_handle()',l_retval,sqlerrm);
      return null;
    end if; 


    declare
    begin 
      l_retval := DBMS_LDAP_UTL.get_subscriber_dn(v_session,subscriber_handle,subscriber_dn);
      if oid_ldap_debug.active_trace=true then 
        trace('__get_subscriber_dn Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('get_default_realm','DBMS_LDAP_UTL.get_subscriber_dn()',l_retval,sqlerrm);
        return null;
      end;   
    end;
    if l_retval!=DBMS_LDAP_UTL.SUCCESS THEN 
      print_error('get_default_realm','DBMS_LDAP_UTL.get_subscriber_dn()',l_retval,sqlerrm);
      return null;
    end if; 
   


    declare
    begin 
      DBMS_LDAP_UTL.free_handle(subscriber_handle);
      if oid_ldap_debug.active_trace=true then 
        trace('__free_handle Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('get_default_realm','DBMS_LDAP_UTL.free_handle()',l_retval,sqlerrm);
        return null;
      end;   
    end;

    if subscriber_dn is null then
      subscriber_dn:=default_realm;
    end if;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function get_default_realm() ...');
    end if; 

    return subscriber_dn;

  end get_default_realm;



  function init_oid(ssl boolean default false) return pls_integer is
    l_retval pls_integer:=-1;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function init_oid() ...');
    end if; 

    DBMS_LDAP.USE_EXCEPTION := TRUE;
    l_retval:=-1;
    v_session:=null;

    declare
    begin
      if ssl=false then
        v_session := DBMS_LDAP.init(ldap_host,ldap_port);
      else
        v_session := DBMS_LDAP.init(ldap_host,ldap_port_ssl);
      end if;
      if oid_ldap_debug.active_trace=true then 
        trace('__Ldap session '||': '||RAWTOHEX(v_session)||'(returned from init)');
      end if; 
    exception
    when others then
      begin
        print_error('init_oid','DBMS_LDAP.init()',l_retval,sqlerrm);
        return -1;
      end;   
    end;

    if ssl=true then    
      declare
      begin
        l_retval:= DBMS_LDAP.open_ssl(v_session,
                  NULL,        -- This parameter specifies the wallet location. Required for one-way or two-way SSL connections.
                  NULL,        -- This parameter specifies the wallet password. Required for one-way or two-way SSL connections.
                  1); -- NO_AUTH     : 1
                      -- ONE_WAY_AUTH: 2
                      -- TWO_WAY_AUTH: 3
        if oid_ldap_debug.active_trace=true then 
          trace('__open_ssl Returns '||': '||TO_CHAR(l_retval));
        end if;
      exception
      when others then
        begin
          print_error('init_oid','DBMS_LDAP.open_ssl()',l_retval,sqlerrm);
          return -1;
        end; 
      end;
    end if;

    declare
    begin
      l_retval := DBMS_LDAP.simple_bind_s(v_session,ldap_user,ldap_passwd);
      if oid_ldap_debug.active_trace=true then 
        trace('__simple_bind_s Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('init_oid','DBMS_LDAP.simple_bind_s()',l_retval,sqlerrm);
        return -1;
      end; 
    end;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function init_oid() ...');
    end if; 

    l_retval:=dbms_ldap.success;
    return l_retval;

  end init_oid;




  
  function close_oid return pls_integer is
    l_retval pls_integer:=-1;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function close_oid() ...');
    end if; 

    l_retval:=-1;

    if v_session is not null then
      declare
      begin
        l_retval := DBMS_LDAP.unbind_s(v_session);
        if oid_ldap_debug.active_trace=true then 
          trace('__unbind_res Returns '||': '||TO_CHAR(l_retval));
        end if;
      exception
      when others then
        begin
          print_error('close_oid','DBMS_LDAP.unbind_s()',l_retval,sqlerrm);
          return -1;
        end;
      end;

    end if;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function close_oid() ...');
    end if; 

    v_session:=null; 

    l_retval:=dbms_ldap.success;
    return l_retval;

  end close_oid; 



  function find_group_and_get_dn(p_group_name in varchar2) return varchar2 is
    v_dn varchar2(32000):=null;
    v_ldap_base  VARCHAR2(32000):='cn=Groups,'||ldap_base;
    v_message    DBMS_LDAP.message;
    v_attrs    DBMS_LDAP.STRING_COLLECTION ;
    entry_index pls_integer;
    cnt pls_integer;
    l_retval pls_integer:=-1;
    v_entry   DBMS_LDAP.message;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function find_group_and_get_dn() ...');
    end if; 

    v_attrs(1) := 'cn';

    declare
    begin
      l_retval := DBMS_LDAP.search_s(
                        v_session,
                        v_ldap_base,
                        DBMS_LDAP.SCOPE_SUBTREE,
                        '(&'||'(cn='||p_group_name||')'||v_group_search_filter||')',
                        v_attrs,
                        0,
                        v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__search_s Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('find_group_and_get_dn','DBMS_LDAP.search_s()',l_retval,sqlerrm);      
        return null;
      end;
    end; 

    declare
    begin
      cnt:= DBMS_LDAP.count_entries(v_session,v_message);
      if cnt>1 then
        if oid_ldap_debug.active_trace=true then 
          trace('__A number of '||to_char(cnt)||' have been found for the group name '||p_group_name||'. The last entry will be returned.');
        end if;
      end if;
    exception
    when others then
      begin
        print_error('find_group_and_get_dn','DBMS_LDAP.count_entries()',l_retval,sqlerrm);      
        return null;
      end;  
    end;

    declare
    begin
      v_entry := DBMS_LDAP.first_entry(v_session, v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__first_entry Returns '||': '||rawtohex(v_entry));
      end if;
    exception
    when others then
       begin
        print_error('find_group_and_get_dn','DBMS_LDAP.first_entry()',l_retval,sqlerrm);      
        return null;
       end;
    end;

    entry_index := 1;
    while v_entry IS NOT NULL loop

      declare
      begin
        v_dn:=DBMS_LDAP.get_dn(v_session,v_entry);
        if oid_ldap_debug.active_trace=true then 
          trace('__get_dn Returns '||': '||v_dn); 
        end if;
      exception
      when others then
         begin
           print_error('find_group_and_get_dn','DBMS_LDAP.get_dn()',l_retval,sqlerrm);      
           return null;
         end;
      end;

      declare
      begin
        v_entry := DBMS_LDAP.next_entry(v_session,v_entry);
        if oid_ldap_debug.active_trace=true then 
          trace('__next_entry Returns '||': '||rawtohex(v_entry));
        end if;
        entry_index := entry_index + 1;
      exception
      when others then
         begin
           print_error('find_group_and_get_dn','DBMS_LDAP.next_entry()',l_retval,sqlerrm);      
           return null;
         end;
      end;

    end loop;

    declare
    begin 
      l_retval := DBMS_LDAP.msgfree(v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__msgfree Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('find_group_and_get_dn','DBMS_LDAP.msgfree()',l_retval,sqlerrm);      
        return null;
      end;
    end;
    if oid_ldap_debug.active_trace=true then 
      trace('exit function find_group_and_get_dn() ...');
    end if; 

    return v_dn;

  end find_group_and_get_dn;




  function find_user_and_get_dn(p_user_name in varchar2) return varchar2 is
    v_dn varchar2(32000):=null;
    v_ldap_base  VARCHAR2(32000):=ldap_base;
    v_message    DBMS_LDAP.message;
    v_attrs    DBMS_LDAP.STRING_COLLECTION ;
    entry_index pls_integer;
    cnt pls_integer;
    l_retval pls_integer:=-1;
    v_entry   DBMS_LDAP.message;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function find_user_and_get_dn() ...');
    end if; 

    v_attrs(1) := 'uid';

    declare
    begin
      l_retval := DBMS_LDAP.search_s(
                        v_session,
                        v_ldap_base,
                        DBMS_LDAP.SCOPE_SUBTREE,
                        '(&'||'(uid='||p_user_name||')'||v_user_search_filter||')',
                        v_attrs,
                        0,
                        v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__search_s Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('find_user_and_get_dn','DBMS_LDAP.search_s()',l_retval,sqlerrm);      
        return null;
      end;
    end; 

    declare
    begin
      cnt:= DBMS_LDAP.count_entries(v_session,v_message);
        if oid_ldap_debug.active_trace=true then 
          trace('__count_entries Returns '||': '||to_char(cnt));
        end if;
      if cnt>1 then
        if oid_ldap_debug.active_trace=true then 
          trace('__A number of '||to_char(cnt)||' have been found for the user name '||p_user_name||'. The last entry will be returned.');
        end if;
      end if;
    exception
    when others then
      begin
        print_error('find_user_and_get_dn','DBMS_LDAP.count_entries()',l_retval,sqlerrm);      
        return null;
      end;  
    end;

    declare
    begin
      v_entry := DBMS_LDAP.first_entry(v_session, v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__first_entry Returns '||': '||rawtohex(v_entry));
      end if;
    exception
    when others then
       begin
        print_error('find_user_and_get_dn','DBMS_LDAP.first_entry()',l_retval,sqlerrm);      
        return null;
       end;
    end;

    entry_index := 1;
    while v_entry IS NOT NULL loop

      declare
      begin
        v_dn:=DBMS_LDAP.get_dn(v_session,v_entry);
        if oid_ldap_debug.active_trace=true then 
          trace('__get_dn Returns '||': '||v_dn);
        end if; 
      exception
      when others then
         begin
           print_error('find_user_and_get_dn','DBMS_LDAP.get_dn()',l_retval,sqlerrm);      
           return null;
         end;
      end;

      declare
      begin
        v_entry := DBMS_LDAP.next_entry(v_session,v_entry);
        if oid_ldap_debug.active_trace=true then 
          trace('__next_entry Returns '||': '||rawtohex(v_entry));
        end if;
        entry_index := entry_index + 1;
      exception
      when others then
         begin
           print_error('find_user_and_get_dn','DBMS_LDAP.next_entry()',l_retval,sqlerrm);      
           return null;
         end;
      end;

    end loop;

    declare
    begin 
      l_retval := DBMS_LDAP.msgfree(v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__msgfree Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('find_user_and_get_dn','DBMS_LDAP.msgfree()',l_retval,sqlerrm);      
        return null;
      end;
    end;
    if oid_ldap_debug.active_trace=true then 
      trace('exit function find_user_and_get_dn() ...');
    end if; 

    return v_dn;

  end find_user_and_get_dn;




 
  function create_group(
            p_group_name      in varchar2, 
            p_description       in varchar2 default null,
            p_displayname       in varchar2 default null,
            p_master_group_name   in varchar2 default null
  ) return pls_integer is
    v_dn varchar2(32000):=null;
    v_dn_master varchar2(32000):=null;
    l_retval pls_integer:=-1;
    v_ldap_base  VARCHAR2(32000):='cn=Groups,'||ldap_base;
    v_array   DBMS_LDAP.MOD_ARRAY;
    v_vals    DBMS_LDAP.STRING_COLLECTION ;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function create_group() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('create_group','init_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    declare
    begin
      v_array:= DBMS_LDAP.create_mod_array(20);
      if oid_ldap_debug.active_trace=true then 
        trace('__create_mod_array ...');
      end if;
    exception
    when others then
      begin
        print_error('create_group','DBMS_LDAP.create_mod_array()',l_retval,sqlerrm);
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;
    end;

    declare
    begin
      v_vals(1):= p_group_name;
      DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'cn',v_vals);
      if oid_ldap_debug.active_trace=true then 
        trace('__populate_mod_array ...');
      end if;
    exception
    when others then
      begin
        print_error('create_group','DBMS_LDAP.populate_mod_array()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;
    end;

    declare 
    begin
      if p_description is null then
        v_vals(1):= p_group_name;
      else
        v_vals(1):=p_description; 
      end if;
      DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'description',v_vals);
      if oid_ldap_debug.active_trace=true then 
        trace('__populate_mod_array ...');
      end if;
    exception
    when others then
      begin
        print_error('create_group','DBMS_LDAP.populate_mod_array()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;
    end;

    declare 
    begin
      if p_displayname is null then
        v_vals(1):= p_group_name;
      else
        v_vals(1):= p_displayname;
      end if;
      DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'displayname',v_vals);
      if oid_ldap_debug.active_trace=true then 
        trace('__populate_mod_array ...');
      end if;
    exception
    when others then
      begin
        print_error('create_group','DBMS_LDAP.populate_mod_array()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;
    end;

    declare 
    begin
      v_vals(1) := 'top';
      v_vals(2) := 'groupOfUniqueNames';
      v_vals(3) := 'orclGroup';
      v_vals(4) := 'orclprivilegegroup';
      DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'objectclass',v_vals);
      if oid_ldap_debug.active_trace=true then 
        trace('__populate_mod_array ...');
      end if;
    exception
    when others then
      begin
        print_error('create_group','DBMS_LDAP.populate_mod_array()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;
    end;

    v_vals.DELETE;

    if p_master_group_name is not null then
      v_dn_master:=null;
      v_dn_master:=find_group_and_get_dn(p_master_group_name);
      if oid_ldap_debug.active_trace=true then 
        trace('__find_group_and_get_dn Returns '||': '||v_dn_master);
      end if;
      if v_dn_master is not null then
        v_ldap_base:=v_dn_master;
      end if;
    end if;

    v_dn := 'cn=' || p_group_name||','||v_ldap_base ;
    if oid_ldap_debug.active_trace=true then 
      trace('__Adding Entry for DN '||': ['||v_dn||']');
    end if;


    declare
    begin
      l_retval := DBMS_LDAP.add_s(v_session,v_dn,v_array);
      if oid_ldap_debug.active_trace=true then 
        trace('__add_s Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('create_group','DBMS_LDAP.add_s()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;
    end;

    declare
    begin
      DBMS_LDAP.free_mod_array(v_array);
      if oid_ldap_debug.active_trace=true then 
        trace('__free_mod_array ...');
      end if;
    exception
    when others then
      begin
        print_error('create_group','DBMS_LDAP.free_mod_array()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;
    end;

    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('create_group','close_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function create_group() ...');
    end if; 

    l_retval:=dbms_ldap.success;
    return l_retval;

  end create_group;





  function list_groups return pls_integer is
    v_dn varchar2(32000):=null;
    v_ldap_base  VARCHAR2(32000):='cn=Groups,'||ldap_base;
    v_message    DBMS_LDAP.message;
    v_attrs    DBMS_LDAP.STRING_COLLECTION ;
    entry_index pls_integer;
    cnt pls_integer;
    l_retval pls_integer;
    v_entry   DBMS_LDAP.message;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function list_groups() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('list_groups','init_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    v_attrs(1) := 'cn';

    declare
    begin
      l_retval := DBMS_LDAP.search_s(
                        v_session,
                        v_ldap_base,
                        DBMS_LDAP.SCOPE_SUBTREE,
                        '(&'||v_group_search_filter||')',
                        v_attrs,
                        0,
                        v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__search_s Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('list_groups','DBMS_LDAP.search_s()',l_retval,sqlerrm);
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;
    end; 

    declare
    begin
      cnt:= DBMS_LDAP.count_entries(v_session,v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__count_entries Returns '||': '||TO_CHAR(cnt));
      end if;
    exception
    when others then
      begin
        print_error('list_groups','DBMS_LDAP.count_entries()',l_retval,sqlerrm);
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;

    declare
    begin
      v_entry := DBMS_LDAP.first_entry(v_session, v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__first_entry Returns '||': '||rawtohex(v_entry));
      end if;
    exception
    when others then
       begin
        print_error('list_groups','DBMS_LDAP.first_entry()',l_retval,sqlerrm);
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
       end;
    end;

    entry_index := 1;
    while v_entry IS NOT NULL loop

      declare
      begin
        v_dn:=DBMS_LDAP.get_dn(v_session,v_entry);
        dbms_output.put_line(rpad('DN Group Entry '||to_char(entry_index),50,' ')||': '||v_dn); 
      exception
      when others then
         begin
           print_error('list_groups','DBMS_LDAP.get_dn()',l_retval,sqlerrm);
           if v_session is not null then
             l_retval:=close_oid();
           end if;       
           return -1;
         end;
      end;

      declare
      begin
        v_entry := DBMS_LDAP.next_entry(v_session,v_entry);
        if oid_ldap_debug.active_trace=true then 
          trace('__next_entry Returns '||': '||rawtohex(v_entry));
        end if;
        entry_index := entry_index + 1;
      exception
      when others then
         begin
           print_error('list_groups','DBMS_LDAP.next_entry()',l_retval,sqlerrm);
           if v_session is not null then
             l_retval:=close_oid();
           end if;       
           return -1;
         end;
      end;

    end loop;

    declare
    begin 
      l_retval := DBMS_LDAP.msgfree(v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__msgfree Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('list_groups','DBMS_LDAP.msgfree()',l_retval,sqlerrm);
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;
    end;

    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('list_groups','close_oid()',l_retval,sqlerrm);
      return -1;
    end if;
    if oid_ldap_debug.active_trace=true then 
      trace('exit function list_groups() ...');
    end if; 

    l_retval:=dbms_ldap.success;
    return l_retval;

  end list_groups;




  function delete_group(p_group_name in varchar2) return pls_integer is
    v_dn varchar2(32000):=null;
    v_ldap_base  VARCHAR2(32000):='cn=Groups,'||ldap_base;
    l_retval pls_integer:=-1;
    retval pls_integer:=-1;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function delete_group() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('delete_group','init_oid()',l_retval,sqlerrm);
      return -1;
    end if;


    v_dn := find_group_and_get_dn(p_group_name);
    if oid_ldap_debug.active_trace=true then 
      trace('__find_group_and_get_dn Returns '||': ['|| v_dn ||']');
    end if;

    if v_dn is not null then
      declare
      begin
        l_retval := DBMS_LDAP.delete_s(v_session,v_dn);
        retval:=l_retval; 
        if oid_ldap_debug.active_trace=true then 
          trace('__delete_s Returns '||': '||TO_CHAR(l_retval));
        end if;
      exception
      when others then
        begin
          print_error('delete_group','DBMS_LDAP.delete_s()',l_retval,sqlerrm);
          if v_session is not null then
            l_retval:=close_oid();
          end if;       
          return -1;
        end; 
      end;
    else
      retval:=-1;
    end if;

    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('delete_group','close_oid()',l_retval,sqlerrm);
      return -1;
    end if;
    if oid_ldap_debug.active_trace=true then 
      trace('exit function delete_group() ...');
    end if; 

    l_retval:=retval; 
    return l_retval;

  end delete_group;



  function create_user(
            p_user_name in varchar2,
                        p_user_type in varchar2 default 'OID',
            p_users_realm in varchar2 default null,
                        p_cn in varchar2 default null,
                        p_sn in varchar2 default null,
                        p_givenname in varchar2 default null,
                        p_krbprincipalname in varchar2 default null,
                        p_displayname in varchar2 default null,
                        p_mail in varchar2 default null,
                        p_orclisenabled in varchar2 default null,
                        p_userpassword in varchar2 default null,
                        p_orclsamaccountname in varchar2 default null,
                        p_orcluserprincipalname in varchar2 default null,
                        p_useraccountcontrol in varchar2 default null
        ) return pls_integer is
    v_dn varchar2(32000):=null;
    l_ldap_base  VARCHAR2(32000):=null;
    l_retval pls_integer:=-1;
    v_array   DBMS_LDAP.MOD_ARRAY;
    v_vals    DBMS_LDAP.STRING_COLLECTION;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function create_user() ...');
    end if; 
  
    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('create_user','init_oid()',l_retval,sqlerrm);
      return -1;
    end if;


    v_array := DBMS_LDAP.create_mod_array(25);
    if oid_ldap_debug.active_trace=true then 
      trace('__create_mod_array ...');
    end if;

    v_vals(1) := p_user_name;
    DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'uid',v_vals);
    if oid_ldap_debug.active_trace=true then 
      trace('__populate_mod_array ...');
    end if;


    if p_cn is null then
      v_vals(1) := p_user_name;
    else
      v_vals(1) := p_cn;
    end if; 
    DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'cn',v_vals);
    if oid_ldap_debug.active_trace=true then 
      trace('__populate_mod_array ...');
    end if;


    if p_sn is null then
      v_vals(1) := p_user_name;
    else
      v_vals(1) := p_sn;
    end if; 
    DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'sn',v_vals);
    if oid_ldap_debug.active_trace=true then 
      trace('__populate_mod_array ...');
    end if;

    if p_givenname is null then
      v_vals(1) := p_user_name;
    else
      v_vals(1) := p_givenname;
    end if; 
    DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'givenname',v_vals);
    if oid_ldap_debug.active_trace=true then 
      trace('__populate_mod_array ...');
    end if;

    if p_krbprincipalname is null then
      v_vals(1) := p_user_name;
    else
      v_vals(1) := p_krbprincipalname;
    end if; 
    DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'krbprincipalname',v_vals);
    if oid_ldap_debug.active_trace=true then 
      trace('__populate_mod_array ...');
    end if;

    if p_displayname is null then
      v_vals(1) := p_user_name;
    else
      v_vals(1) := p_displayname;
    end if; 
    DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'displayname',v_vals);
    if oid_ldap_debug.active_trace=true then 
      trace('__populate_mod_array ...');
    end if;

    if p_mail is null then
      v_vals(1) := p_user_name;
    else
      v_vals(1) := p_mail;
    end if; 
    DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'mail',v_vals);
    if oid_ldap_debug.active_trace=true then 
      trace('__populate_mod_array ...');
    end if;


    if upper(p_user_type)='OID' then

      if p_orclisenabled is null then
        v_vals(1) := 'ENABLED';
      else
        v_vals(1) := p_orclisenabled;
      end if; 
      DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'orclisenabled',v_vals);
      if oid_ldap_debug.active_trace=true then 
        trace('__populate_mod_array ...');
      end if;

      if p_userpassword is null then
        v_vals(1) := p_user_name;
      else
        v_vals(1) := p_userpassword;
      end if; 
      DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'userpassword',v_vals);
      if oid_ldap_debug.active_trace=true then 
        trace('__populate_mod_array ...');
      end if;

    end if;

    ----- Marius ------ commented because of objectclass=aduser

    if upper(p_user_type)<>'OID' then

      if p_orclsamaccountname is null then
        v_vals(1) := p_user_name;
      else
        v_vals(1) := p_orclsamaccountname;
      end if; 
      DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'orclsamaccountname',v_vals);
      if oid_ldap_debug.active_trace=true then 
        trace('__populate_mod_array ...');
      end if;


      if p_orcluserprincipalname is null then
        v_vals(1) := p_user_name;
      else
        v_vals(1) := p_orcluserprincipalname;
      end if; 
      DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'orcluserprincipalname',v_vals);
      if oid_ldap_debug.active_trace=true then 
        trace('__populate_mod_array ...');
      end if;


      if p_useraccountcontrol is null then
        v_vals(1) := '512';
      else
        v_vals(1) := p_useraccountcontrol;
      end if; 
      DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'useraccountcontrol',v_vals);
      if oid_ldap_debug.active_trace=true then 
        trace('__populate_mod_array ...');
      end if;
    
    end if;


    --- the user search filter is :    (objectclass=top)(objectclass=inetorgperson)(objectclass=organizationalPerson)(objectclass=person)

    if upper(p_user_type)='OID' then
      v_vals(1) := 'inetorgperson';
      v_vals(2) := 'orcluserv2';
      v_vals(3) := 'person';
      v_vals(4) := 'orcluser';
      v_vals(5) := 'top';
      v_vals(6) := 'organizationalPerson';
      if oid_ldap_debug.active_trace=true then 
        trace('__will create an OID-like user. ');
      end if;
    else    --- should be an AD user not correctly imported 
      v_vals(1) := 'aduser';
      v_vals(2) := 'inetorgperson';
      v_vals(3) := 'orcluserv2';
      v_vals(4) := 'person';
      v_vals(5) := 'orcladuser';
      v_vals(6) := 'orclcontainer';
      v_vals(7) := 'top';
      v_vals(8) := 'organizationalPerson';
      if oid_ldap_debug.active_trace=true then 
        trace('__will create an Windows AD-like user. ');
      end if;
    end if;


    DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'objectclass',v_vals);
    if oid_ldap_debug.active_trace=true then 
      trace('__populate_mod_array ...');
    end if;

    v_vals.DELETE;

    if p_users_realm is not null then
      l_ldap_base:=p_users_realm;
    else
      l_ldap_base:='cn=Users,'||get_default_realm;
    end if;
  
    v_dn := 'uid='||p_user_name||','||l_ldap_base ;
    if oid_ldap_debug.active_trace=true then 
      trace('__Adding Entry for DN '||': ['||v_dn||']');
    end if;

    declare
    begin
      l_retval := DBMS_LDAP.add_s(v_session,v_dn,v_array);
      if oid_ldap_debug.active_trace=true then 
        trace('__add_s Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
       begin
          print_error('create_user','DBMS_LDAP.add_s()',l_retval,sqlerrm);
          if v_session is not null then
            l_retval:=close_oid();
          end if;       
          return -1;
       end;
    end;

    declare
    begin
      DBMS_LDAP.free_mod_array(v_array);
      if oid_ldap_debug.active_trace=true then 
        trace('__free_mod_array ...');
      end if;
    exception
    when others then
       begin
          print_error('create_user','DBMS_LDAP.delete_s()',l_retval,sqlerrm);
          if v_session is not null then
            l_retval:=close_oid();
          end if;       
          return -1;
       end;
    end;

    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('create_user','close_oid()',l_retval,sqlerrm);
      return -1;
    end if;
    if oid_ldap_debug.active_trace=true then 
      trace('exit function create_user() ...');
    end if; 

    l_retval:=dbms_ldap.success;
    return l_retval;

  end create_user;





  function delete_user(p_user_name in varchar2) return pls_integer is
    v_dn varchar2(32000):=null;
    l_retval pls_integer:=-1;
    ret_l_retval pls_integer:=-1;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function delete_user() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('delete_user','init_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    v_dn :=find_user_and_get_dn(p_user_name);
    if oid_ldap_debug.active_trace=true then 
      trace('__find_user_and_get_dn Returns '||': ['|| v_dn ||']');
    end if;

    if v_dn is not null then

      declare
      begin
        l_retval := DBMS_LDAP.delete_s(v_session,v_dn);
        if oid_ldap_debug.active_trace=true then 
          trace('__delete_s Returns '||': '||TO_CHAR(l_retval));
        end if;
      exception
      when others then
         begin
            print_error('delete_user','DBMS_LDAP.delete_s()',l_retval,sqlerrm);
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return -1;
         end;
      end;
      ret_l_retval:=l_retval;
    else
      ret_l_retval:=-1;
    end if;

    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('delete_user','close_oid()',l_retval,sqlerrm);
      return -1;
    end if;
    if oid_ldap_debug.active_trace=true then 
      trace('exit function delete_user() ...');
    end if; 

    l_retval:=ret_l_retval;
    return l_retval;

  end delete_user;




  function authenticate_user(p_user_name in varchar2,p_password in varchar2) return pls_integer is
    l_retval pls_integer:=-1;
    ret_l_retval pls_integer:=-1;
    v_dn varchar2(32000):=null;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function authenticate_user() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('authenticate_user','init_oid()',l_retval,sqlerrm);
      return -1;
    end if;
    

    v_dn :=find_user_and_get_dn(p_user_name);
    if oid_ldap_debug.active_trace=true then 
      trace('__find_user_and_get_dn Returns '||': ['|| v_dn ||']');
    end if;


    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('authenticate_user','close_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    l_retval:=-1;

    if v_dn is not null then
      declare
      begin
        v_session := DBMS_LDAP.init(ldap_host,ldap_port);
        if oid_ldap_debug.active_trace=true then 
          trace('__Ldap session '||': '||RAWTOHEX(v_session)||'(returned from init)');
        end if; 
      exception
      when others then
        begin
          print_error('authenticate_user','DBMS_LDAP.init()',l_retval,sqlerrm);
          return -1;
        end;   
      end;
      declare
      begin
        l_retval := DBMS_LDAP.simple_bind_s(v_session,v_dn,p_password);
        if oid_ldap_debug.active_trace=true then 
          trace('__simple_bind_s Returns '||': '||TO_CHAR(l_retval));
        end if;
        if l_retval=dbms_ldap.success then
          DBMS_OUTPUT.PUT_LINE('__We have successfully authenticate the user '||p_user_name||'.');
          ret_l_retval:=dbms_ldap.success;
        else
          DBMS_OUTPUT.PUT_LINE('__Unauthenticated user '||p_user_name||'. Invalid username/password.');
          ret_l_retval:=-1;
        end if;
      exception
      when others then
        begin
          print_error('authenticate_user','DBMS_LDAP.simple_bind_s()',l_retval,sqlerrm);
          return -1;
        end; 
      end;
      declare
      begin
        l_retval := DBMS_LDAP.unbind_s(v_session);
        if oid_ldap_debug.active_trace=true then 
          trace('__unbind_res Returns '||': '||TO_CHAR(l_retval));
        end if;
      exception
      when others then
        begin
          print_error('authenticate_user','DBMS_LDAP.unbind_s()',l_retval,sqlerrm);
          return -1;
        end;
      end;
    else
      ret_l_retval:=-1;
    end if;
 
    if oid_ldap_debug.active_trace=true then 
      trace('exit function authenticate_user() ...');
    end if; 

    return ret_l_retval;

  end authenticate_user;




  function add_user_to_group(p_user_name in varchar2,p_group_name in varchar2) return pls_integer is
    l_retval pls_integer:=-1;
    ret_l_retval pls_integer:=-1;
    v_user_dn varchar2(32000):=null;
    v_group_dn varchar2(32000):=null;
    v_array   DBMS_LDAP.MOD_ARRAY;
    v_vals    DBMS_LDAP.STRING_COLLECTION;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function add_user_to_group() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('add_user_to_group','init_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    v_group_dn :=find_group_and_get_dn(p_group_name);
    if oid_ldap_debug.active_trace=true then 
      trace('__find_group_and_get_dn Returns '||': ['|| v_group_dn ||']');
    end if;

    if v_group_dn is not null then

      v_user_dn :=find_user_and_get_dn(p_user_name);
      if oid_ldap_debug.active_trace=true then 
        trace('__find_user_and_get_dn Returns '||': ['|| v_user_dn ||']');
      end if;

      if v_user_dn is not null then
      
        declare
        begin
          v_array := DBMS_LDAP.create_mod_array(1);
          if oid_ldap_debug.active_trace=true then 
            trace('__create_mod_array ...');
          end if;
        exception
        when others then
          begin
            print_error('add_user_to_group','DBMS_LDAP.create_mod_array()',l_retval,sqlerrm);
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return -1;
          end;
        end;

        v_vals(1) := v_user_dn;

        declare
        begin
          DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_ADD,'uniquemember',v_vals);
          if oid_ldap_debug.active_trace=true then 
            trace('__populate_mod_array ...');
          end if;
        exception
        when others then
          begin
            print_error('add_user_to_group','DBMS_LDAP.populate_mod_array()',l_retval,sqlerrm);
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return -1;
          end;
        end;


        declare
        begin
          l_retval := DBMS_LDAP.modify_s(v_session,v_group_dn,v_array);
          if oid_ldap_debug.active_trace=true then 
            trace('__modify_s Returns '||': '||TO_CHAR(l_retval));
          end if;
          ret_l_retval:=l_retval;
        exception
        when others then
          begin
            print_error('add_user_to_group','DBMS_LDAP.modify_s()',l_retval,sqlerrm);
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return -1;
          end;
        end;


        declare
        begin
          DBMS_LDAP.free_mod_array(v_array);
          if oid_ldap_debug.active_trace=true then 
            trace('__free_mod_array ...');
          end if;
        exception
        when others then
          begin
            print_error('add_user_to_group','DBMS_LDAP.free_mod_array()',l_retval,sqlerrm);
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return -1;
          end;
        end;
      else
        if oid_ldap_debug.active_trace=true then 
          trace('__User does not exists or invalid user name (be careful to case sensitivity).');
        end if;
        ret_l_retval:=-1;
      end if;
    else
      if oid_ldap_debug.active_trace=true then 
        trace('__Group does not exists or invalid group name (be careful to case sensitivity).');
      end if;
      ret_l_retval:=-1;
    end if; 

    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('add_user_to_group','close_oid()',l_retval,sqlerrm);
      return -1;
    end if;


    if oid_ldap_debug.active_trace=true then 
      trace('exit function add_user_to_group() ...');
    end if; 

    return ret_l_retval;

  end add_user_to_group;




  function remove_user_from_group(p_user_name in varchar2,p_group_name in varchar2) return pls_integer is
    l_retval pls_integer:=-1;
    ret_l_retval pls_integer:=-1;
    v_user_dn varchar2(32000):=null;
    v_group_dn varchar2(32000):=null;
    v_array   DBMS_LDAP.MOD_ARRAY;
    v_vals    DBMS_LDAP.STRING_COLLECTION;
    v_check_result pls_integer:=-1;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function remove_user_from_group() ...');
    end if; 

    v_check_result:=check_group_membership(p_user_name,p_group_name);
    if oid_ldap_debug.active_trace=true then 
      trace('__check_group_membership Returns '||to_char(v_check_result));
    end if;

    if v_check_result=dbms_ldap.success then

      l_retval:=init_oid();
      if oid_ldap_debug.active_trace=true then 
        trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
      end if;

      if l_retval!=dbms_ldap.success then
        print_error('remove_user_from_group','init_oid()',l_retval,sqlerrm);
        return -1;
      end if;

      v_group_dn :=find_group_and_get_dn(p_group_name);
      if oid_ldap_debug.active_trace=true then 
        trace('__find_group_and_get_dn Returns '||': ['|| v_group_dn ||']');
      end if;

      if v_group_dn is not null then
        v_user_dn :=find_user_and_get_dn(p_user_name);
        if oid_ldap_debug.active_trace=true then 
          trace('__find_user_and_get_dn Returns '||': ['|| v_user_dn ||']');
        end if;
        if v_user_dn is not null then
          declare
          begin
            v_array := DBMS_LDAP.create_mod_array(1);
            if oid_ldap_debug.active_trace=true then 
              trace('__create_mod_array ...');
            end if;
          exception
          when others then
            begin
              print_error('remove_user_from_group','DBMS_LDAP.create_mod_array()',l_retval,sqlerrm);
              if v_session is not null then
                l_retval:=close_oid();
              end if;       
              return -1;
            end;
          end;
          v_vals(1) := v_user_dn;
          declare
          begin
            DBMS_LDAP.populate_mod_array(v_array,DBMS_LDAP.MOD_DELETE,'uniquemember',v_vals);
            if oid_ldap_debug.active_trace=true then 
              trace('__populate_mod_array ...');
            end if;
          exception
          when others then
            begin
              print_error('remove_user_from_group','DBMS_LDAP.populate_mod_array()',l_retval,sqlerrm);
              if v_session is not null then
                l_retval:=close_oid();
              end if;       
              return -1;
            end;
          end;
          declare
          begin
            l_retval := DBMS_LDAP.modify_s(v_session,v_group_dn,v_array);
            if oid_ldap_debug.active_trace=true then 
              trace('__modify_s Returns '||': '||TO_CHAR(l_retval));
            end if;
            ret_l_retval:=l_retval;
          exception
          when others then
            begin
              print_error('remove_user_from_group','DBMS_LDAP.modify_s()',l_retval,sqlerrm);
              if v_session is not null then
                l_retval:=close_oid();
              end if;       
              return -1;
            end;
          end;
          declare
          begin
            DBMS_LDAP.free_mod_array(v_array);
            if oid_ldap_debug.active_trace=true then 
              trace('__free_mod_array ...');
            end if;
          exception
          when others then
            begin
              print_error('remove_user_from_group','DBMS_LDAP.free_mod_array()',l_retval,sqlerrm);
              if v_session is not null then
                l_retval:=close_oid();
              end if;       
              return -1;
            end;
          end;
        else
          if oid_ldap_debug.active_trace=true then 
            trace('__User does not exists or invalid user name (be careful to case sensitivity).');
          end if;
          ret_l_retval:=-1;
        end if;
      else
        if oid_ldap_debug.active_trace=true then 
          trace('__Group does not exists or invalid group name (beware to case sensitivity).');
        end if;
        ret_l_retval:=-1;
      end if; 
      l_retval:=close_oid();
      if oid_ldap_debug.active_trace=true then 
        trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
      end if;
      if l_retval!=dbms_ldap.success then
        print_error('remove_user_from_group','close_oid()',l_retval,sqlerrm);
        return -1;
      end if;
    else
      ret_l_retval:=v_check_result;
    end if;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function remove_user_from_group() ...');
    end if; 

    return ret_l_retval;

  end remove_user_from_group;


  function print_group(p_group_name in varchar2) return pls_integer is
    l_retval pls_integer:=-1;
    ret_l_retval pls_integer:=-1;
    v_attrs     DBMS_LDAP.string_collection;
    v_message   DBMS_LDAP.message;
    v_entry     DBMS_LDAP.message;
    entry_index  PLS_INTEGER;
    v_attr_name VARCHAR2(256);
    v_ber_elmt  DBMS_LDAP.ber_element;
    attr_index   PLS_INTEGER;
    i          PLS_INTEGER;
    v_vals DBMS_LDAP.STRING_COLLECTION ;
    v_dn varchar2(32000):=null;
    v_ldap_base  VARCHAR2(32000):='cn=Groups,'||ldap_base;
    cnt pls_integer:=0;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function print_group() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('print_group','init_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    v_attrs(1) := '*';

    declare
    begin
      l_retval := DBMS_LDAP.search_s(
                        v_session,
                        v_ldap_base,
                        DBMS_LDAP.SCOPE_SUBTREE,
                        '(&'||'(cn='||p_group_name||')'||v_group_search_filter||')',
                        v_attrs,
                        0,
                        v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__search_s Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('print_group','DBMS_LDAP.search_s()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return null;
      end;
    end; 

    declare
    begin
      cnt:= DBMS_LDAP.count_entries(v_session,v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__count_entries Returns '||': '||TO_CHAR(cnt));
      end if;
      if cnt>1 then
        if oid_ldap_debug.active_trace=true then 
          trace('__A number of '||to_char(cnt)||' have been found for the group name '||p_group_name||'. The last entry will be returned.');
        end if;
      end if;
    exception
    when others then
      begin
        print_error('print_group','DBMS_LDAP.count_entries()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return null;
      end;  
    end;

    if cnt>=1 then
      declare
      begin
        v_entry := DBMS_LDAP.first_entry(v_session, v_message);
        if oid_ldap_debug.active_trace=true then 
          trace('__first_entry Returns '||': '||rawtohex(v_entry));
        end if;
      exception
      when others then
         begin
          print_error('print_group','DBMS_LDAP.first_entry()',l_retval,sqlerrm);      
          if v_session is not null then
            l_retval:=close_oid();
          end if;       
          return null;
         end;
      end;
      entry_index := 1;
      while v_entry IS NOT NULL loop
        declare
        begin
          v_dn:=DBMS_LDAP.get_dn(v_session,v_entry);
          if oid_ldap_debug.active_trace=true then 
            trace('__get_dn Returns '||': '||v_dn);
          end if;
        exception
        when others then
          begin
            print_error('print_group','DBMS_LDAP.get_dn()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;
        dbms_output.put_line('DN : '||v_dn); 
        declare
        begin
          v_attr_name := DBMS_LDAP.first_attribute(v_session,v_entry,v_ber_elmt);
          if oid_ldap_debug.active_trace=true then 
            trace('__first_attribute Returns '||': '||v_attr_name);
          end if;
        exception
        when others then
          begin
            print_error('print_group','DBMS_LDAP.first_attribute()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;
        attr_index := 1;
        while v_attr_name IS NOT NULL loop
          declare
          begin
            v_vals := DBMS_LDAP.get_values(v_session,v_entry,v_attr_name);
            if oid_ldap_debug.active_trace=true then 
              trace('__get_values ...');
            end if;
          exception
          when others then
            begin
              print_error('print_group','DBMS_LDAP.get_values()',l_retval,sqlerrm);      
              if v_session is not null then
                l_retval:=close_oid();
              end if;       
              return null;
            end;
          end;
          if v_vals.COUNT > 0 then
            FOR i in v_vals.FIRST..v_vals.LAST loop
              DBMS_OUTPUT.PUT_LINE('           ' || v_attr_name || ' : ' ||SUBSTR(v_vals(i),1,200));
            end loop;
          end if;
          declare
          begin
            v_attr_name := DBMS_LDAP.next_attribute(v_session,v_entry,v_ber_elmt);
            if oid_ldap_debug.active_trace=true then 
              trace('__next_attribute Returns '||': '||v_attr_name);
            end if;
          exception
          when others then
            begin
              print_error('print_group','DBMS_LDAP.next_attribute()',l_retval,sqlerrm);      
              if v_session is not null then
                l_retval:=close_oid();
              end if;       
              return null;
            end;
          end;
          attr_index := attr_index+1;
        end loop;
        declare
        begin
          DBMS_LDAP.ber_free(v_ber_elmt, 0);
          if oid_ldap_debug.active_trace=true then 
            trace('__ber_free ...');
          end if;
        exception
        when others then
          begin
            print_error('print_group','DBMS_LDAP.ber_free()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;
        dbms_output.put_line(' ');
        declare
        begin
          v_entry := DBMS_LDAP.next_entry(v_session,v_entry);
          if oid_ldap_debug.active_trace=true then 
            trace('__next_entry Returns '||': '||rawtohex(v_entry));
          end if;
          entry_index := entry_index + 1;
        exception
        when others then
          begin
            print_error('print_group','DBMS_LDAP.next_entry()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;
      end loop;
      declare
      begin 
        l_retval := DBMS_LDAP.msgfree(v_message);
        if oid_ldap_debug.active_trace=true then 
          trace('__msgfree ...');
        end if;
      exception
      when others then
        begin
          print_error('print_group','DBMS_LDAP.msgfree()',l_retval,sqlerrm);      
          if v_session is not null then
            l_retval:=close_oid();
          end if;       
          return null;
        end;
      end;
      ret_l_retval:=dbms_ldap.success;
    else
      trace('__Invalid group name '||p_group_name||' (be careful to case sensitivity).');
      ret_l_retval:=-1;
    end if;

    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('print_group','close_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function print_group() ...');
    end if; 

    return ret_l_retval;
  
  end print_group;



  function print_user(p_user_name in varchar2) return pls_integer is
    l_retval pls_integer:=-1;
    ret_l_retval pls_integer:=-1;
    v_attrs     DBMS_LDAP.string_collection;
    v_message   DBMS_LDAP.message;
    v_entry     DBMS_LDAP.message;
    entry_index  PLS_INTEGER;
    v_attr_name VARCHAR2(256);
    v_ber_elmt  DBMS_LDAP.ber_element;
    attr_index   PLS_INTEGER;
    i          PLS_INTEGER;
    v_vals DBMS_LDAP.STRING_COLLECTION ;
    v_dn varchar2(32000):=null;
    v_ldap_base  VARCHAR2(32000):=ldap_base;
    cnt pls_integer:=0;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function print_user() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('print_user','init_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    v_attrs(1) := '*';

    declare
    begin
      l_retval := DBMS_LDAP.search_s(
                        v_session,
                        v_ldap_base,
                        DBMS_LDAP.SCOPE_SUBTREE,
                        '(&'||'(uid='||p_user_name||')'||v_user_search_filter||')',
                        v_attrs,
                        0,
                        v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__search_s Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('print_user','DBMS_LDAP.search_s()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return null;
      end;
    end; 

    declare
    begin
      cnt:= DBMS_LDAP.count_entries(v_session,v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__count_entries Returns '||': '||TO_CHAR(cnt));
      end if;
    exception
    when others then
      begin
        print_error('print_user','DBMS_LDAP.count_entries()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return null;
      end;  
    end;

    if cnt>=1 then
      declare
      begin
        v_entry := DBMS_LDAP.first_entry(v_session, v_message);
        if oid_ldap_debug.active_trace=true then 
          trace('__first_entry Returns '||': '||rawtohex(v_entry));
        end if;
      exception
      when others then
        begin
          print_error('print_user','DBMS_LDAP.first_entry()',l_retval,sqlerrm);      
          if v_session is not null then
            l_retval:=close_oid();
          end if;       
          return null;
         end;
      end;
      entry_index := 1;
      while v_entry IS NOT NULL loop
        declare
        begin
          v_dn:=DBMS_LDAP.get_dn(v_session,v_entry);
          if oid_ldap_debug.active_trace=true then 
            trace('__get_dn Returns '||': '||v_dn);
          end if;
        exception
        when others then
          begin
            print_error('print_user','DBMS_LDAP.get_dn()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;
        dbms_output.put_line('DN : '||v_dn); 
        declare
        begin
          v_attr_name := DBMS_LDAP.first_attribute(v_session,v_entry,v_ber_elmt);
          if oid_ldap_debug.active_trace=true then 
            trace('__first_attribute Returns '||': '||v_attr_name);
          end if;
        exception
        when others then
          begin
            print_error('print_user','DBMS_LDAP.first_attribute()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;
        attr_index := 1;
        while v_attr_name IS NOT NULL loop
          declare
          begin
            v_vals := DBMS_LDAP.get_values(v_session,v_entry,v_attr_name);
            if oid_ldap_debug.active_trace=true then 
              trace('__get_values ...');
            end if;
          exception
          when others then
            begin
              print_error('print_user','DBMS_LDAP.get_values()',l_retval,sqlerrm);      
              if v_session is not null then
                l_retval:=close_oid();
              end if;       
              return null;
            end;
          end;
          if v_vals.COUNT > 0 then
            FOR i in v_vals.FIRST..v_vals.LAST loop
              DBMS_OUTPUT.PUT_LINE('           ' || v_attr_name || ' : ' ||SUBSTR(v_vals(i),1,200));
            end loop;
          end if;
          declare
          begin
            v_attr_name := DBMS_LDAP.next_attribute(v_session,v_entry,v_ber_elmt);
            if oid_ldap_debug.active_trace=true then 
              trace('__next_attribute Returns '||': '||v_attr_name);
            end if;
          exception
          when others then
            begin
              print_error('print_user','DBMS_LDAP.next_attribute()',l_retval,sqlerrm);      
              if v_session is not null then
                l_retval:=close_oid();
              end if;       
              return null;
            end;
          end;
          attr_index := attr_index+1;
        end loop;
        declare
        begin
          DBMS_LDAP.ber_free(v_ber_elmt, 0);
          if oid_ldap_debug.active_trace=true then 
            trace('__ber_free ...');
          end if;
        exception
        when others then
          begin
            print_error('print_user','DBMS_LDAP.ber_free()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;
        dbms_output.put_line(' ');
        declare
        begin
          v_entry := DBMS_LDAP.next_entry(v_session,v_entry);
          if oid_ldap_debug.active_trace=true then 
            trace('__next_entry Returns '||': '||rawtohex(v_entry));
          end if;
          entry_index := entry_index + 1;
        exception
        when others then
          begin
            print_error('print_user','DBMS_LDAP.next_entry()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;
      end loop;
      declare
      begin 
        l_retval := DBMS_LDAP.msgfree(v_message);
        if oid_ldap_debug.active_trace=true then 
          trace('__msgfree ...');
        end if;
      exception
      when others then
        begin
          print_error('print_user','DBMS_LDAP.msgfree()',l_retval,sqlerrm);      
          if v_session is not null then
            l_retval:=close_oid();
          end if;       
          return null;
        end;
      end;
      ret_l_retval:=dbms_ldap.success;
    else
      if oid_ldap_debug.active_trace=true then 
        trace('__Invalid user name '||p_user_name||' (be careful to case sensitivity).');
      end if;
      ret_l_retval:=-1;
    end if;

    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('print_user','close_oid()',l_retval,sqlerrm);
      return -1;
    end if;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function print_user() ...');
    end if; 

    l_retval:=ret_l_retval;
    return l_retval;
  
  end print_user;


  function get_user_attr(p_user_name in varchar2,p_attr_name in varchar2) return varchar2 is
    l_retval pls_integer:=-1;
    v_attrs     DBMS_LDAP.string_collection;
    v_message   DBMS_LDAP.message;
    v_entry     DBMS_LDAP.message;
    entry_index  PLS_INTEGER;
    v_attr_name VARCHAR2(256);
    v_ber_elmt  DBMS_LDAP.ber_element;
    attr_index   PLS_INTEGER;
    i          PLS_INTEGER;
    v_vals DBMS_LDAP.STRING_COLLECTION ;
    v_dn varchar2(32000):=null;
    v_ldap_base  VARCHAR2(32000):=ldap_base;
    cnt pls_integer:=0;
    v_attr_val varchar2(32000):=null;
  begin
    if oid_ldap_debug.active_trace=true then 
      trace('in function get_user_attr() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('get_user_attr','init_oid()',l_retval,sqlerrm);
      return null;
    end if;




    v_attrs(1) := p_attr_name;

    declare
    begin
      l_retval := DBMS_LDAP.search_s(
                        v_session,
                        v_ldap_base,
                        DBMS_LDAP.SCOPE_SUBTREE,
                        '(&'||'(uid='||p_user_name||')'||v_user_search_filter||')',
                        v_attrs,
                        0,
                        v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__search_s Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('get_user_attr','DBMS_LDAP.search_s()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return null;
      end;
    end; 

    declare
    begin
      cnt:= DBMS_LDAP.count_entries(v_session,v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__count_entries Returns '||': '||TO_CHAR(cnt));
      end if;
    exception
    when others then
      begin
        print_error('get_user_attr','DBMS_LDAP.count_entries()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return null;
      end;  
    end;

    if cnt>=1 then

    declare
    begin
      v_entry := DBMS_LDAP.first_entry(v_session, v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__first_entry Returns '||': '||rawtohex(v_entry));
      end if;
    exception
    when others then
       begin
        print_error('get_user_attr','DBMS_LDAP.first_entry()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return null;
       end;
    end;

    entry_index := 1;
    while v_entry IS NOT NULL loop

      declare
      begin
        v_dn:=DBMS_LDAP.get_dn(v_session,v_entry);
        if oid_ldap_debug.active_trace=true then 
          trace('__get_dn Returns '||': '||v_dn);
        end if;
      exception
      when others then
         begin
           print_error('get_user_attr','DBMS_LDAP.get_dn()',l_retval,sqlerrm);      
           if v_session is not null then
             l_retval:=close_oid();
           end if;       
           return null;
         end;
      end;

      declare
      begin
        v_attr_name := DBMS_LDAP.first_attribute(v_session,v_entry,v_ber_elmt);
        if oid_ldap_debug.active_trace=true then 
          trace('__first_attribute Returns '||': '||v_attr_name);
        end if;
      exception
      when others then
         begin
           print_error('get_user_attr','DBMS_LDAP.first_attribute()',l_retval,sqlerrm);      
           if v_session is not null then
             l_retval:=close_oid();
           end if;       
           return null;
         end;
      end;

      if v_attr_name is null then
        l_retval := DBMS_LDAP.msgfree(v_message);
        l_retval:=close_oid();
        return null;  
      end if;

      attr_index := 1;
      while v_attr_name IS NOT NULL loop

        declare
        begin
          v_vals := DBMS_LDAP.get_values(v_session,v_entry,v_attr_name);
          if oid_ldap_debug.active_trace=true then 
            trace('__get_values Returns '||': '||to_char(v_vals.count));
          end if;
        exception
        when others then
          begin
            print_error('get_user_attr','DBMS_LDAP.get_values()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;

      
        if v_vals.COUNT > 0 then
          FOR i in v_vals.FIRST..v_vals.LAST loop
            v_attr_val:=v_vals(i);
            if oid_ldap_debug.active_trace=true then 
              trace('           ' || v_attr_name || ' : ' ||SUBSTR(v_vals(i),1,200));
            end if; 
          end loop;
        end if;

        declare
        begin
          v_attr_name := DBMS_LDAP.next_attribute(v_session,v_entry,v_ber_elmt);
          if oid_ldap_debug.active_trace=true then 
            trace('__next_attribute Returns '||': '||v_attr_name);
          end if;
        exception
        when others then
          begin
            print_error('get_user_attr','DBMS_LDAP.next_attribute()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;

        attr_index := attr_index+1;
      end loop;
    
      if attr_index>1 then
        declare
        begin
          DBMS_LDAP.ber_free(v_ber_elmt, 0);
          if oid_ldap_debug.active_trace=true then 
            trace('__ber_free ...');
          end if;
        exception
        when others then
          begin
            print_error('get_user_attr','DBMS_LDAP.ber_free()',l_retval,sqlerrm);      
            if v_session is not null then
              l_retval:=close_oid();
            end if;       
            return null;
          end;
        end;
      end if;


      declare
      begin
        v_entry := DBMS_LDAP.next_entry(v_session,v_entry);
        if oid_ldap_debug.active_trace=true then 
          trace('__next_entry Returns '||': '||rawtohex(v_entry));
        end if;
        entry_index := entry_index + 1;
      exception
      when others then
         begin
           print_error('get_user_attr','DBMS_LDAP.next_entry()',l_retval,sqlerrm);      
           if v_session is not null then
             l_retval:=close_oid();
           end if;       
          return null;
         end;
      end;

    end loop;

    declare
    begin 
      l_retval := DBMS_LDAP.msgfree(v_message);
      if oid_ldap_debug.active_trace=true then 
        trace('__msgfree ...');
      end if;
    exception
    when others then
      begin
        print_error('get_user_attr','DBMS_LDAP.msgfree()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return null;
      end;
    end;

    else
      if oid_ldap_debug.active_trace=true then 
        trace('__Invalid user name '||p_user_name||' (be careful to case sensitivity).');
      end if;
    end if;



    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('get_user_attr','close_oid()',l_retval,sqlerrm);
      return null;
    end if;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function get_user_attr() ...');
    end if; 

    return v_attr_val;
  
  end get_user_attr;



  function check_group_membership(
            p_user_name  in varchar2,
            p_group_name in varchar2
        ) return pls_integer is
    l_retval    pls_integer:=-1;
    sub_type PLS_INTEGER;
    subscriber_id VARCHAR2(2000);
    subscriber_handle DBMS_LDAP_UTL.HANDLE;
    user_handle DBMS_LDAP_UTL.HANDLE;
    user_type PLS_INTEGER;
    group_type PLS_INTEGER;
    group_handle DBMS_LDAP_UTL.HANDLE;
    save_retval pls_integer:=-1;
  begin

    sub_type := DBMS_LDAP_UTL.TYPE_DEFAULT;
    subscriber_id := NULL;
    user_type := DBMS_LDAP_UTL.TYPE_NICKNAME;
    group_type := DBMS_LDAP_UTL.TYPE_NICKNAME;


    if oid_ldap_debug.active_trace=true then 
      trace('in function check_group_membership() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('check_group_membership','init_oid()',l_retval,sqlerrm);
      return null;
    end if;



    declare
    begin
      l_retval := DBMS_LDAP_UTL.create_subscriber_handle(subscriber_handle,sub_type,subscriber_id);
      if oid_ldap_debug.active_trace=true then 
        trace('__create_subscriber_handle Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('check_group_membership','DBMS_LDAP_UTL.create_subscriber_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;


    declare
    begin
      l_retval := DBMS_LDAP_UTL.create_user_handle(user_handle,user_type,p_user_name);
      if oid_ldap_debug.active_trace=true then 
        trace('__create_user_handle Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('check_group_membership','DBMS_LDAP_UTL.create_user_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;


    declare
    begin
      l_retval := DBMS_LDAP_UTL.set_user_handle_properties(user_handle,DBMS_LDAP_UTL.SUBSCRIBER_HANDLE,subscriber_handle);
      if oid_ldap_debug.active_trace=true then 
        trace('__set_user_handle_properties Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('check_group_membership','DBMS_LDAP_UTL.set_user_handle_properties()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;

    declare
    begin
      l_retval := DBMS_LDAP_UTL.create_group_handle(group_handle,group_type,p_group_name);
      if oid_ldap_debug.active_trace=true then 
        trace('__create_group_handle Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('check_group_membership','DBMS_LDAP_UTL.create_group_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;

    declare
    begin
      l_retval := DBMS_LDAP_UTL.set_group_handle_properties(group_handle,DBMS_LDAP_UTL.SUBSCRIBER_HANDLE,subscriber_handle);
      if oid_ldap_debug.active_trace=true then 
        trace('__set_group_handle_properties Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('check_group_membership','DBMS_LDAP_UTL.set_group_handle_properties()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;


    declare
    begin
      l_retval := DBMS_LDAP_UTL.check_group_membership(v_session,user_handle,group_handle,DBMS_LDAP_UTL.DIRECT_MEMBERSHIP);
      if oid_ldap_debug.active_trace=true then 
        trace('__check_group_membership Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('check_group_membership','DBMS_LDAP_UTL.check_group_membership()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;
    save_retval:=l_retval;

    declare
    begin
      DBMS_LDAP_UTL.free_handle(subscriber_handle);
      if oid_ldap_debug.active_trace=true then 
        trace('__free_handle Returns '||': ');
      end if;
    exception
    when others then
      begin
        print_error('check_group_membership','DBMS_LDAP_UTL.free_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;


    declare
    begin
      DBMS_LDAP_UTL.free_handle(user_handle);
      if oid_ldap_debug.active_trace=true then 
        trace('__free_handle Returns '||': ');
      end if;
    exception
    when others then
      begin
        print_error('check_group_membership','DBMS_LDAP_UTL.free_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;

    declare
    begin
      DBMS_LDAP_UTL.free_handle(group_handle);
      if oid_ldap_debug.active_trace=true then 
        trace('__free_handle Returns '||': ');
      end if;
    exception
    when others then
      begin
        print_error('check_group_membership','DBMS_LDAP_UTL.free_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;



    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('check_group_membership','close_oid()',l_retval,sqlerrm);
      return null;
    end if;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function check_group_membership() ...');
    end if; 


    return save_retval;

  end check_group_membership;

  function get_group_membership(
            p_user_name  in varchar2
        ) return pls_integer is
    l_retval    pls_integer:=-1;
    sub_type PLS_INTEGER;
    subscriber_id VARCHAR2(2000);
    subscriber_handle DBMS_LDAP_UTL.HANDLE;
    user_handle DBMS_LDAP_UTL.HANDLE;
    user_type PLS_INTEGER;
    save_retval pls_integer:=-1;
    v_attrs DBMS_LDAP.STRING_COLLECTION;
    v_pset_coll DBMS_LDAP_UTL.PROPERTY_SET_COLLECTION;
    v_property_names DBMS_LDAP.STRING_COLLECTION;
    v_property_values DBMS_LDAP.STRING_COLLECTION;
    v_message    DBMS_LDAP.message;
    entry_index pls_integer;
    v_entry   DBMS_LDAP.message;
    v_dn varchar2(32000):=null;
  begin

    sub_type := DBMS_LDAP_UTL.TYPE_DEFAULT;
    subscriber_id := NULL;
    user_type := DBMS_LDAP_UTL.TYPE_NICKNAME;


    if oid_ldap_debug.active_trace=true then 
      trace('in function get_group_membership() ...');
    end if; 

    l_retval:=init_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__init_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('get_group_membership','init_oid()',l_retval,sqlerrm);
      return null;
    end if;



    declare
    begin
      l_retval := DBMS_LDAP_UTL.create_subscriber_handle(subscriber_handle,sub_type,subscriber_id);
      if oid_ldap_debug.active_trace=true then 
        trace('__create_subscriber_handle Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('get_group_membership','DBMS_LDAP_UTL.create_subscriber_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;


    declare
    begin
      l_retval := DBMS_LDAP_UTL.create_user_handle(user_handle,user_type,p_user_name);
      if oid_ldap_debug.active_trace=true then 
        trace('__create_user_handle Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('get_group_membership','DBMS_LDAP_UTL.create_user_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;


    declare
    begin
      l_retval := DBMS_LDAP_UTL.set_user_handle_properties(user_handle,DBMS_LDAP_UTL.SUBSCRIBER_HANDLE,subscriber_handle);
      if oid_ldap_debug.active_trace=true then 
        trace('__set_user_handle_properties Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('get_group_membership','DBMS_LDAP_UTL.set_user_handle_properties()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;


    v_attrs(1) := 'uid';
    declare
    begin
      l_retval := DBMS_LDAP_UTL.get_group_membership(v_session,user_handle,DBMS_LDAP_UTL.NESTED_MEMBERSHIP,v_attrs,v_pset_coll );
      if oid_ldap_debug.active_trace=true then 
        trace('__get_group_membership Returns '||': '||TO_CHAR(l_retval));
      end if;
    exception
    when others then
      begin
        print_error('get_group_membership','DBMS_LDAP_UTL.get_group_membership()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;
    save_retval:=l_retval;


    v_attrs.delete;

    if l_retval=DBMS_LDAP_UTL.SUCCESS then

      IF v_pset_coll.count > 0 THEN
        FOR i in v_pset_coll.first .. v_pset_coll.last LOOP
          declare
          begin
            l_retval := DBMS_LDAP_UTL.get_property_names(v_pset_coll(i),v_property_names);
            if oid_ldap_debug.active_trace=true then 
              trace('__get_property_names Returns '||': '||TO_CHAR(l_retval));
            end if;
          exception
          when others then
            begin
              print_error('get_group_membership','DBMS_LDAP_UTL.get_property_names()',l_retval,sqlerrm);      
              if v_session is not null then
                l_retval:=close_oid();
              end if;       
              return -1;
            end;  
          end;
          IF v_property_names.count > 0 THEN
            FOR j in v_property_names.first .. v_property_names.last LOOP
              declare
              begin
                l_retval := DBMS_LDAP_UTL.get_property_values(v_pset_coll(i),v_property_names(j),v_property_values);
                if oid_ldap_debug.active_trace=true then 
                  trace('__get_property_names Returns '||': '||TO_CHAR(l_retval));
                end if;
              exception
              when others then
                begin
                  print_error('get_group_membership','DBMS_LDAP_UTL.get_property_names()',l_retval,sqlerrm);      
                  if v_session is not null then
                    l_retval:=close_oid();
                  end if;       
                  return -1;
                end;  
              end;
              IF v_property_values.COUNT > 0 THEN
                FOR k in v_property_values.FIRST..v_property_values.LAST LOOP
                  v_attrs(1) := 'orclguid';
                  declare
                  begin
                    l_retval := DBMS_LDAP.search_s(v_session,ldap_base,DBMS_LDAP.SCOPE_SUBTREE,'(&'||'(orclguid='||v_property_values(k)||')'||')',v_attrs,0,v_message);
                    if oid_ldap_debug.active_trace=true then 
                      trace('__search_s Returns '||': '||TO_CHAR(l_retval));
                    end if;
                  exception
                  when others then
                    begin
                      print_error('get_group_membership','DBMS_LDAP.search_s()',l_retval,sqlerrm);      
                      if v_session is not null then
                        l_retval:=close_oid();
                      end if;       
                      return -1;
                    end;  
                  end;
                  declare
                  begin
                    v_entry := DBMS_LDAP.first_entry(v_session, v_message);
                    if oid_ldap_debug.active_trace=true then 
                      trace('__first_entry Returns '||': '||rawtohex(v_entry));
                    end if;
                  exception
                  when others then
                    begin
                      print_error('get_group_membership','DBMS_LDAP.first_entry()',l_retval,sqlerrm);      
                      if v_session is not null then
                        l_retval:=close_oid();
                      end if;       
                      return -1;
                    end;  
                  end;
                  entry_index := 1;
                  while v_entry IS NOT NULL loop
                    declare
                    begin
                      v_dn:=DBMS_LDAP.get_dn(v_session,v_entry);
                      if oid_ldap_debug.active_trace=true then 
                        trace('__get_dn Returns '||': '||v_dn); 
                      end if;
                    exception
                    when others then
                      begin
                        print_error('get_group_membership','DBMS_LDAP.get_dn()',l_retval,sqlerrm);      
                        if v_session is not null then
                          l_retval:=close_oid();
                        end if;       
                        return -1;
                      end;
                    end;

                    dbms_output.put_line(v_dn); 

                    entry_index:=entry_index+1;    
                    declare
                    begin
                      v_entry := DBMS_LDAP.next_entry(v_session,v_entry);
                      if oid_ldap_debug.active_trace=true then 
                        trace('__next_entry Returns '||': '||rawtohex(v_entry));
                      end if;
                    exception
                    when others then
                      begin
                        print_error('get_group_membership','DBMS_LDAP.next_entry()',l_retval,sqlerrm);      
                        if v_session is not null then
                          l_retval:=close_oid();
                        end if;       
                        return -1;
                      end;  
                    end;
                  end loop;
                  declare
                  begin
                    l_retval := DBMS_LDAP.msgfree(v_message);
                    if oid_ldap_debug.active_trace=true then 
                      trace('__msgfree Returns '||': '||TO_CHAR(l_retval));
                    end if;
                  exception
                  when others then
                    begin
                      print_error('get_group_membership','DBMS_LDAP.msgfree()',l_retval,sqlerrm);      
                      if v_session is not null then
                        l_retval:=close_oid();
                      end if;       
                      return -1;
                    end;  
                  end;
                END LOOP;
              END IF;
            END LOOP;
          END IF; -- IF my_property_names.count > 0
        END LOOP;
      END IF; -- If my_pset_coll.count > 0

    end if;

    declare
    begin
      DBMS_LDAP_UTL.free_propertyset_collection(v_pset_coll);
      if oid_ldap_debug.active_trace=true then 
        trace('__free_propertyset_collection Returns '||': ');
      end if;
    exception
    when others then
      begin
        print_error('get_group_membership','DBMS_LDAP_UTL.free_propertyset_collection()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;


    declare
    begin
      DBMS_LDAP_UTL.free_handle(subscriber_handle);
      if oid_ldap_debug.active_trace=true then 
        trace('__free_handle Returns '||': ');
      end if;
    exception
    when others then
      begin
        print_error('get_group_membership','DBMS_LDAP_UTL.free_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;


    declare
    begin
      DBMS_LDAP_UTL.free_handle(user_handle);
      if oid_ldap_debug.active_trace=true then 
        trace('__free_handle Returns '||': ');
      end if;
    exception
    when others then
      begin
        print_error('get_group_membership','DBMS_LDAP_UTL.free_handle()',l_retval,sqlerrm);      
        if v_session is not null then
          l_retval:=close_oid();
        end if;       
        return -1;
      end;  
    end;

    l_retval:=close_oid();
    if oid_ldap_debug.active_trace=true then 
      trace('__close_oid Returns '||': '||TO_CHAR(l_retval));
    end if;

    if l_retval!=dbms_ldap.success then
      print_error('get_group_membership','close_oid()',l_retval,sqlerrm);
      return null;
    end if;

    if oid_ldap_debug.active_trace=true then 
      trace('exit function get_group_membership() ...');
    end if; 


    return save_retval;

  end get_group_membership;



begin
  -- Choosing exceptions to be raised by DBMS_LDAP library.
  DBMS_LDAP.USE_EXCEPTION := TRUE;

end oid_ldap_pkg;
/
show errors



