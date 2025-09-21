spool /tmp/scott.log

rem create user scott identified by tiger default tablespace users;
rem grant connect,resource,unlimited tablespace to scott;


DROP TABLE scott.emp            CASCADE CONSTRAINTS;
DROP TABLE scott.dept           CASCADE CONSTRAINTS;
DROP TABLE scott.bonus          CASCADE CONSTRAINTS;
DROP TABLE scott.salgrade       CASCADE CONSTRAINTS;
DROP TABLE scott.dummy          CASCADE CONSTRAINTS;
DROP TABLE scott.test_lob       CASCADE CONSTRAINTS;
DROP TABLE scott.countries      CASCADE CONSTRAINTS;
DROP MATERIALIZED VIEW LOG ON scott.emp;
DROP MATERIALIZED VIEW scott.emp_mv;
DROP TABLE scott.emp_mv         CASCADE CONSTRAINTS;

CREATE TABLE scott.dept(
        deptno  NUMBER(2) CONSTRAINT PK_DEPT PRIMARY KEY
       ,dname   VARCHAR2(14)
       ,loc     VARCHAR2(13)
) PARTITION BY RANGE(deptno)
(
        PARTITION p_10          VALUES LESS THAN(20)
       ,PARTITION p_20          VALUES LESS THAN(30)
       ,PARTITION p_30          VALUES LESS THAN(40)
       ,PARTITION p_40          VALUES LESS THAN(50)
       ,PARTITION p_others      VALUES LESS THAN(maxvalue)
);
INSERT INTO scott.dept VALUES(10,'ACCOUNTING'   ,'NEW YORK');
INSERT INTO scott.dept VALUES(20,'RESEARCH'     ,'DALLAS');
INSERT INTO scott.dept VALUES(30,'SALES'        ,'CHICAGO');
INSERT INTO scott.dept VALUES(40,'OPERATIONS'   ,'BOSTON');
COMMIT;

CREATE TABLE scott.emp(
        empno           NUMBER(4) NOT NULL CONSTRAINT PK_EMP PRIMARY KEY
       ,ename           VARCHAR2(10)
       ,job             VARCHAR2(9)
       ,mgr             NUMBER(4)
       ,hiredate        DATE
       ,sal             NUMBER(7,2)
       ,comm            NUMBER(7,2)
       ,deptno          NUMBER(2) CONSTRAINT FK_DEPTNO REFERENCES scott.DEPT
) PARTITION BY RANGE(deptno)
(
        PARTITION p_10          VALUES LESS THAN(20)
       ,PARTITION p_20          VALUES LESS THAN(30)
       ,PARTITION p_30          VALUES LESS THAN(40)
       ,PARTITION p_40          VALUES LESS THAN(50)
       ,PARTITION p_others      VALUES LESS THAN(maxvalue)
);

CREATE INDEX scott.emp_idx ON scott.emp(deptno) LOCAL; 

CREATE TABLE scott.bonus(
        ename   VARCHAR2(10)
       ,job     VARCHAR2(9)
       ,sal     NUMBER
       ,comm    NUMBER
);

CREATE TABLE scott.salgrade(
        grade NUMBER
       ,losal NUMBER
       ,hisal NUMBER
);

INSERT INTO scott.salgrade VALUES(1,700 ,1200);
INSERT INTO scott.salgrade VALUES(2,1201,1400);
INSERT INTO scott.salgrade VALUES(3,1401,2000);
INSERT INTO scott.salgrade VALUES(4,2001,3000);
INSERT INTO scott.salgrade VALUES(5,3001,9999);
COMMIT;

CREATE TABLE scott.dummy(
        dummy NUMBER
);
INSERT INTO scott.dummy VALUES(0);
COMMIT;

INSERT INTO scott.emp VALUES(7369,'SMITH' ,'CLERK'    ,7902,TO_DATE('17-DEC-1980','DD-MON-YYYY'),800 ,NULL,20);
INSERT INTO scott.emp VALUES(7499,'ALLEN' ,'SALESMAN' ,7698,TO_DATE('20-FEB-1981','DD-MON-YYYY'),1600,300 ,30);
INSERT INTO scott.emp VALUES(7521,'WARD'  ,'SALESMAN' ,7698,TO_DATE('22-FEB-1981','DD-MON-YYYY'),1250,500 ,30);
INSERT INTO scott.emp VALUES(7566,'JONES' ,'MANAGER'  ,7839,TO_DATE('2-APR-1981' ,'DD-MON-YYYY'),2975,NULL,20);
INSERT INTO scott.emp VALUES(7654,'MARTIN','SALESMAN' ,7698,TO_DATE('28-SEP-1981','DD-MON-YYYY'),1250,1400,30);
INSERT INTO scott.emp VALUES(7698,'BLAKE' ,'MANAGER'  ,7839,TO_DATE('1-MAY-1981' ,'DD-MON-YYYY'),2850,NULL,30);
INSERT INTO scott.emp VALUES(7782,'CLARK' ,'MANAGER'  ,7839,TO_DATE('9-JUN-1981' ,'DD-MON-YYYY'),2450,NULL,10);
INSERT INTO scott.emp VALUES(7788,'SCOTT' ,'ANALYST'  ,7566,TO_DATE('09-DEC-1982','DD-MON-YYYY'),3000,NULL,20);
INSERT INTO scott.emp VALUES(7839,'KING'  ,'PRESIDENT',NULL,TO_DATE('17-NOV-1981','DD-MON-YYYY'),5000,NULL,10);
INSERT INTO scott.emp VALUES(7844,'TURNER','SALESMAN' ,7698,TO_DATE('8-SEP-1981' ,'DD-MON-YYYY'),1500,0   ,30);
INSERT INTO scott.emp VALUES(7876,'ADAMS' ,'CLERK'    ,7788,TO_DATE('12-JAN-1983','DD-MON-YYYY'),1100,NULL,20);
INSERT INTO scott.emp VALUES(7900,'JAMES' ,'CLERK'    ,7698,TO_DATE('3-DEC-1981' ,'DD-MON-YYYY'),950 ,NULL,30);
INSERT INTO scott.emp VALUES(7902,'FORD'  ,'ANALYST'  ,7566,TO_DATE('3-DEC-1981' ,'DD-MON-YYYY'),3000,NULL,20);
INSERT INTO scott.emp VALUES(7934,'MILLER','CLERK'    ,7782,TO_DATE('23-JAN-1982','DD-MON-YYYY'),1300,NULL,10);
COMMIT;


CREATE TABLE scott.test_lob AS SELECT * FROM SYS.WRI$_DBU_FEATURE_METADATA;

CREATE MATERIALIZED VIEW LOG ON scott.emp
WITH PRIMARY KEY
INCLUDING NEW VALUES;

CREATE TABLE scott.emp_mv AS
SELECT * FROM scott.emp;

CREATE MATERIALIZED VIEW scott.emp_mv
ON PREBUILT TABLE
REFRESH FORCE ON DEMAND
AS
SELECT * FROM scott.emp;


CREATE TABLE scott.countries(
        COUNTRY_ID CHAR(2) CONSTRAINT COUNTRY_ID_NN NOT NULL ENABLE,
        COUNTRY_NAME VARCHAR2(40),
        REGION_ID NUMBER,
         CONSTRAINT COUNTRY_C_ID_PK PRIMARY KEY (COUNTRY_ID) ENABLE
) 
ORGANIZATION INDEX NOCOMPRESS ;

INSERT INTO scott.countries VALUES('US','USA',01);
INSERT INTO scott.countries VALUES('FR','FRANCE',02);
INSERT INTO scott.countries VALUES('UK','United Kingdom',03);
commit;

exec dbms_stats.gather_schema_stats(ownname=>'SCOTT',degree=> DBMS_STATS.DEFAULT_DEGREE,estimate_percent=>100,cascade=>true,options=>'GATHER AUTO',granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');

spool off

--BEGIN
--  DBMS_STATS.DROP_STAT_TABLE('scott' ,'savestats');
--  DBMS_STATS.CREATE_STAT_TABLE('scott' ,'savestats');
--  DBMS_STATS.GATHER_TABLE_STATS ('SCOTT', 'EMP', estimate_percent=>dbms_stats.auto_sample_size,method_opt=>'for all columns size 75',granularity=>'ALL',stattab => 'savestats');
--  DBMS_STATS.GATHER_TABLE_STATS ('SCOTT', 'DEPT', stattab => 'savestats');
--end;
--/
--commit;
--SELECT * FROM savestats;
