--
--  Script : url10.sql
--  Purpose: call the scripts @u10, @r10, @l10, @tseg10 et swtx10 to display sessions,rollback segs(undo), locks, and temp segs currently in use
--  For    : 10g+
--
@save_sqp_set

@@u10
@@r10
@@l10
@@tseg10
@@swtx10

@rest_sqp_set
