--
--  Script : url.sql
--  Purpose: call the scripts @u, @r, @l, @tseg, swtx to display sessions,rollback segs(undo), locks, and temp segs currently in use
--  For    : 12c+
--
@save_sqp_set

@@u
@@r
@@l
@@tseg
@@swtx

@rest_sqp_set
