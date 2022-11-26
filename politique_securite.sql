spool politique_securite.log


----------------------------------------------------------------------------------------
-- Script politique_securite.sql
--
-- Date : 21/11/2008
--
-- Auteur : Marius RAICU
--
-- Document de Reference : "Politique de Mise en OEuvre"
--                         creer par Olivier Fourmaux (DSSI) le 13/04/2007
--                         verifier par Philippe Pierandrei (DSSI) le 13/04/2007
--                         approbe  par le Conseil de la Fonction SI le le 13/04/2007
--
-- Le actions effectues par le script politique_securite.sql sont:
--
--  - Creation de la fonction VERIF_SEC_PASSWD, qui est utilise dans le profiles securises
--  - Suppresion des anciennes profiles de securite PASSWORD_LIMIT%
--  - Creation des profiles securises PASSWORD_LIMIT (PASSWORD_LIFE_TIME 365) et PASSWORD_LIMIT_220 (PASSWORD_LIFE_TIME 220)
--  - Bloquage des comptes 'DIP','TSMSYS','OUTLN','DBSNMP','%SHD';
--  - Affectation du profile PASSWORD_LIMIT_220 aux comptes 'SYS','SYSTEM','HP_DBSPI'
--  - Affectation du profile PASSWORD_LIMIT aux comptes 'SAP%' sauf '%SHD'
----------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------
-- Ce fonction permet de fixer les regles pour securiser le mot de passe des users oracle
--
-- Date : 11/10/2007
--
-- Auteur : MH
--
-- Document de Reference : "Politique de Mise en OEuvre"
--                         creer par Olivier Fourmaux (DSSI) le 13/04/2007
--                         verifier par Philippe Pierandrei (DSSI) le 13/04/2007
--                         approbe  par le Conseil de la Fonction SI le le 13/04/2007
----------------------------------------------------------------------------------------
select sysdate from dual;

set lines 200 pages 80

col host_name for a45
select instance_name,host_name,version from v$instance;

select username,account_status,profile,lock_date,expiry_date from dba_users order by 1;

prompt Creation de la fonction VERIF_SEC_PASSWD
CREATE OR REPLACE FUNCTION verif_sec_passwd
(username varchar2,
 password varchar2,
 old_password varchar2)
 RETURN boolean IS
 n integer;
 diff integer;
 digit boolean;
 char  boolean;
 punc boolean;
 digit_array varchar2(20);
 punc_array varchar2(25);
 char_array varchar2(52);

BEGIN
   digit_array:= '0123456789';
   char_array:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
   punc_array:='!"#$%&()``*+,-/:;<=>?_';
   ------------------------------------------------------
   -- Verifier si le password est identique au username
   ------------------------------------------------------
   IF NLS_LOWER(password) = NLS_LOWER(username) THEN
     raise_application_error(-20001, 'Password est identique au username');
   END IF;
   ----------------------------------------------------------------
   -- verifier si le password contient au minimum 8 characteres
   ----------------------------------------------------------------
   IF length(password) < 8 THEN
      raise_application_error(-20002, 'Password doit avoir au minimum 8 characteres ');
   END IF;
   ---------------------------------------------------------------------------------------------------
   -- Verifier si le password contient au moins une lettre, un alphanumerique et un charatere special
   ---------------------------------------------------------------------------------------------------
   digit:=FALSE;
   n := length(password);
   FOR i IN 1..10 LOOP
      FOR j IN 1..n LOOP
         IF substr(password,j,1) = substr(digit_array,i,1) THEN
            digit:=TRUE;
             GOTO findchar;
         END IF;
      END LOOP;
   END LOOP;
   IF digit = FALSE THEN
      raise_application_error(-20003, 'Password doit contenir au moins une lettre, un alphanumerique et un charatere special');
   END IF;
   <<findchar>>
   char:=FALSE;
   FOR i IN 1..length(char_array) LOOP
      FOR j IN 1..n LOOP
         IF substr(password,j,1) = substr(char_array,i,1) THEN
            char:=TRUE;
             GOTO findpunc;
         END IF;
      END LOOP;
   END LOOP;
   IF char = FALSE THEN
      raise_application_error(-20003, 'Password doit contenir au moins une lettre, un alphanumerique et un charatere special');
   END IF;
   <<findpunc>>
   punc:=FALSE;
   FOR i IN 1..length(punc_array) LOOP
      FOR j IN 1..n LOOP
         IF substr(password,j,1) = substr(punc_array,i,1) THEN
            punc:=TRUE;
             GOTO endsearch;
         END IF;
      END LOOP;
   END LOOP;
   IF punc = FALSE THEN
      raise_application_error(-20003, 'Password doit contenir au moins une lettre, un alphanumerique et un charatere special');
   END IF;
   <<endsearch>>
   ------------------------------------------------------------------------------------
   -- Verifier si le password est different des anciens password d'au moins 3 lettres
   ------------------------------------------------------------------------------------
   IF old_password = '' THEN
      raise_application_error(-20004, 'l''ancien password est vide');
   END IF;
   diff := length(old_password) - length(password);
   IF abs(diff) < 3 THEN
      IF length(password) < length(old_password) THEN
         n := length(password);
      ELSE
         n := length(old_password);
      END IF;
      diff := abs(diff);
      FOR i IN 1..n LOOP
          IF substr(password,i,1) != substr(old_password,i,1) THEN
             diff := diff + 1;
          END IF;
      END LOOP;
      IF diff < 3 THEN
          raise_application_error(-20004, 'Password doit etre different des d''anciens au moins 3 characteres');
      END IF;
   END IF;
   ------------------------------------------
   -- Si tout est OK, retourne TRUE
   ------------------------------------------
   RETURN(TRUE);
END;
/
spool off


set lines 200 pages 0 trimspool on trimout on echo off head off
rem Suppresion des profiles PASSWORD_LIMIT%
set termout off
spool /tmp/drop_profiles.sql
prompt prompt Suppresion des profiles PASSWORD_LIMIT%
select 'alter user '||username||' profile DEFAULT;' from dba_users;
select distinct 'drop profile '||profile||';' from dba_profiles where profile like 'PASSWORD%';
spool off
set termout on
spool politique_securite.log APP
@/tmp/drop_profiles.sql
spool off
host rm -f /tmp/drop_profiles.sql


spool politique_securite.log APP
----------------------------------------------------------------------------
-- Ce script permet d'affecter un profile de gestion securisee
-- de mot de passe pour les users oracle
--
-- Date : 11/10/2007
--
-- Auteur : MH
--
-- Document de Reference : "Politique de Mise en OEuvre"
--                         creer par Olivier Fourmaux (DSSI) le 13/04/2007
--                         verifier par Philippe Pierandrei (DSSI) le 13/04/2007
--                         approbe  par le Conseil de la Fonction SI le le 13/04/2007
-----------------------------------------------------------------------------

prompt Creation du profile PASSWORD_LIMIT (PASSWORD_LIFE_TIME 365j)
CREATE PROFILE PASSWORD_LIMIT LIMIT
FAILED_LOGIN_ATTEMPTS 5
PASSWORD_LIFE_TIME 365
PASSWORD_REUSE_MAX 6
PASSWORD_REUSE_TIME 7
PASSWORD_LOCK_TIME UNLIMITED
PASSWORD_GRACE_TIME 0
PASSWORD_VERIFY_FUNCTION VERIF_SEC_PASSWD;

----------------------------------------------------------------------------
-- Ce script permet d'affecter un profile de gestion securisee
-- de mot de passe pour les users oracle
--
-- Date : 11/10/2007
--
-- Auteur : MH
--
-- Document de Reference : "Politique de Mise en OEuvre"
--                         creer par Olivier Fourmaux (DSSI) le 13/04/2007
--                         verifier par Philippe Pierandrei (DSSI) le 13/04/2007
--                         approbe  par le Conseil de la Fonction SI le le 13/04/2007
--  La retention des mots de passe est a 220 jours
-----------------------------------------------------------------------------

prompt Creation du profile PASSWORD_LIMIT_220 (PASSWORD_LIFE_TIME 220j)
CREATE PROFILE PASSWORD_LIMIT_220 LIMIT
FAILED_LOGIN_ATTEMPTS 5
PASSWORD_LIFE_TIME 220
PASSWORD_REUSE_MAX 6
PASSWORD_REUSE_TIME 7
PASSWORD_LOCK_TIME UNLIMITED
PASSWORD_GRACE_TIME 0
PASSWORD_VERIFY_FUNCTION VERIF_SEC_PASSWD;

spool off

set lines 200 pages 0 trimspool on trimout on echo off head off

rem Verrouillage des comptes DIP,TSMSYS,OUTLN,DBSNMP et %SHD
set termout off
spool /tmp/lock_users.sql
prompt prompt Verrouillage des utilisateurs DIP,TSMSYS,OUTLN,DBSNMP et %SHD
select 'alter user '||username||' account lock;' from dba_users where username in ('DIP','TSMSYS','OUTLN','DBSNMP') or username like '%SHD';
spool off
set termout on
spool politique_securite.log APP
@/tmp/lock_users.sql
spool off
host rm -f /tmp/lock_users.sql

rem Simulation de chg de password et profile PASSWORD_LIMIT_220 pour SYS,SYSTEM,HP_DBSPI
set termout off
spool /tmp/password_limit_220.sql
prompt prompt Simulation de chg de password et profile PASSWORD_LIMIT_220 pour SYS,SYSTEM,HP_DBSPI
select 'alter user '||username||' profile DEFAULT;' from dba_users where username in ('SYS','SYSTEM','HP_DBSPI');
select 'alter user '||username||' identified by values '||chr(39)||password||chr(39)||';' from dba_users where username in ('SYS','SYSTEM','HP_DBSPI');
select 'alter user '||username||' profile PASSWORD_LIMIT_220;' from dba_users where username in ('SYS','SYSTEM','HP_DBSPI');
spool off
set termout on
spool politique_securite.log APP
@/tmp/password_limit_220.sql
spool off
host rm -f /tmp/password_limit_220.sql

rem Simulation de chg de password et profile PASSWORD_LIMIT pour les comptes SAP%
set termout off
spool /tmp/password_limit.sql
prompt prompt Simulation de chg de password et profile PASSWORD_LIMIT pour les comptes SAP%
select 'alter user '||username||' profile DEFAULT;' from dba_users where username like 'SAP%' and username not like '%SHD';
select 'alter user '||username||' identified by values '||chr(39)||password||chr(39)||';' from dba_users where username like 'SAP%' and username not like '%SHD';
select 'alter user '||username||' profile PASSWORD_LIMIT;' from dba_users where username like 'SAP%' and username not like '%SHD';
spool off
set termout on
spool politique_securite.log APP
@/tmp/password_limit.sql
spool off
host rm -f /tmp/password_limit.sql

prompt Verifications
set lines 200 pages 80 trimspool on trimout on echo off head on
col object_name for a35
spool politique_securite.log APP

select object_name,object_type,status from dba_objects where object_name='VERIF_SEC_PASSWD';

select * from dba_profiles where profile like 'PASSWORD_LIMIT%' order by 1;

select username,account_status,profile,lock_date,expiry_date from dba_users order by 1;

select sysdate from dual;

prompt Le log d execution est dans le fichier politique_securite.log
spool off
