set serveroutput on
set verify off
declare
  local_node VARCHAR2(128);
  up_node    VARCHAR2(128);
  last_scn   NUMBER;
  last_tid   VARCHAR2(22);
  last_tdb   VARCHAR2(128);
  cnt        NUMBER;
  CURSOR c(last_delivered NUMBER, last_tid VARCHAR2, last_tdb VARCHAR2) IS
    select cscn, enq_tid,
        dscn, DECODE(c.recipient_key, 0, 'D', 'R')
      from system.def$_aqcall c  where
        (c.cscn >= last_delivered)
        and ((c.cscn > last_delivered) or (c.enq_tid > last_tid))
        and (
          ( c.recipient_key = 0
            and exists ( select /*+ index(cd def$_calldest_primary) */ null
            from system.def$_calldest cd
            where cd.enq_tid = c.enq_tid
            and cd.dblink = up_node ) )
          or ( c.recipient_key > 0
            and ( ( exists (
            select null from system.repcat$_repprop P
            where P.dblink = up_node
              and P.how = 1
              and P.recipient_key = c.recipient_key
              and ((P.delivery_order is NULL)
                or (P.delivery_order < c.cscn))))
                or ( exists
                   ( select /*+ ordered use_nl(rp) */ null
                       from system.def$_aqcall cc, system.repcat$_repprop rp
                       where cc.enq_tid = c.enq_tid
                       and cc.cscn is null
                       and rp.recipient_key = cc.recipient_key
                       and rp.how = 1
                       and rp.dblink = up_node
                       and ((rp.delivery_order is NULL)
                         or (rp.delivery_order < c.cscn)))))))
      order by  c.cscn, c.enq_tid;
    r          c%ROWTYPE;
    notfound   BOOLEAN;
  begin
    SELECT NLS_UPPER(global_name) INTO local_node FROM global_name;
    select dblink into up_node from deftrandest
     where dblink like NLS_UPPER ('&destination'||'%')
       and rownum < 2;
    if up_node is null then
      dbms_output.put_line ('Cannot identify destination');
      return;
    else
      dbms_output.put_line ('-------------------------------------------');
      dbms_output.put_line ('Deferred Transactions to '||up_node);
      dbms_output.put_line ('-------------------------------------------');
    end if;
    dbms_output.enable(10000);
    SELECT last_delivered, last_enq_tid, dblink
      INTO last_scn, last_tid, last_tdb
      FROM system.def$_destination
     WHERE dblink = up_node;
    OPEN c(last_scn,last_tid,last_tdb);
    -- Cursor c returns the following:
    --   rid (rowid), deferred_tran_id, deferred_tran_db,
    --   destination_list, origin_user_id, delivery_order,
    --   destination_count
    LOOP
      FETCH c into r;
      notfound:=c%NOTFOUND;
      EXIT WHEN notfound;
   
      SELECT count(*) into cnt from system.def$_aqcall
       WHERE enq_tid = r.enq_tid;
      dbms_output.put_line ('Def.Tran ID='||r.enq_tid
                                ||' - # of calls='||to_char(cnt));
    END LOOP;
    close c;
  end;
/

