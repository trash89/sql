--
--  Script    : arch9.sql
--  Author    : Marius RAICU
--  Purpose   : show ARCHIVE and ARCHIVELOG informations
--  Tested on : Oracle 9.0.1.3

@save_sqlplus_settings
col group# for 999 head 'Gr#'
col thread# format 999 head 'Th#'
col sequence# for 99999999999 head 'Seq#'
col iscurrent for a5 head 'IsCrt'
col current for a5 head 'Crt'
col first_change# for 999999999999 head 'First Change'
select * from v$archive;
@restore_sqlplus_settings
