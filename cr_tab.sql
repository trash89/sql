drop table stats cascade constraints;
create table stats(db_name varchar2(20),process_name varchar2(20),date_time varchar2(20),stat_name varchar2(64),value number)
tablespace queues storage(initial 4K next 4K minextents 2 maxextents unlimited pctincrease 0);
