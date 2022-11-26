rem
rem
rem   Script:     index_estimate.sql
rem   Author:     Jonathan Lewis
rem   Dated:      Aug 2004
rem   Purpose:    How big should an index be.
rem
rem   Notes:
rem   Last tested 10.1.0.4 with 8K blocksize
rem   Last tested  9.2.0.6 with 8K blocksize
rem   Last tested  8.1.7.4 with 8K blocksize
rem
rem   A quick and dirty script to work out roughly
rem   how big a simple b-tree index should be.
rem
rem   Based on a manual method I first used with v6 when
rem   I found the odd index that looked suspiciously large
rem
rem   The concept is simple -
rem         Number of entries in index * entry overhead plus
rem               data content of index entries
rem         Assume 100 bytes per block overhead
rem         Assume 70% packing      (effectively pctfree 30)
rem         Allow 1% for branch blocks
rem
rem   It's not accurate, but it doesn't need to be if
rem   all you want to know is whether the index about
rem   the right size or way off.
rem
rem   Room for error:
rem         Can't cope with rounding errors on avg_col_len
rem         Can't cope with generic function-based indexes
rem         Doesn't allow for compressed indexes
rem         Doesn't allow for large ITLs
rem         Doesn't allow for 'long' columns (>127 bytes)
rem         Doesn't allow for side-effects of null columns
rem
rem   Needs a recent stats collection on the table and index
rem         If you use analyze, then add one to avg_col_len
rem         If you use dbms_stats, don't.
rem
rem   In this example, the block size is hard coded at 8K
rem
rem   If you want to modify this code to produce a version that
rem   handles partitioning, the rowid for a global index or
rem   globally partitioned index is 10 bytes, not 6.
rem
rem   There are a few other considerations for dealing with IOTs
rem   and secondary indexes on IOTs.
rem
 
 
drop table t1;
 
create table t1 
nologging         -- adjust as necessary
pctfree 10        -- adjust as necessary
as
select
      owner,
      object_type, 
      object_name,
      object_id,
      last_ddl_time
from
      all_objects
where
      rownum <= 10000
;
 
 
create index t1_i1 on t1(owner, object_type, object_name);
 
begin
      dbms_stats.gather_table_stats(
            user,
            't1',
            cascade => true,
            estimate_percent => null,
            method_opt => 'for all columns size 1'
      );
end;
/
 
 
rem
rem   To start with, we want:
rem         index_entries (user_indexes.num_rows) * (
rem               rowid entry (6 or 7 depending on uniqueness)
rem               +
rem               4 (rowindex entry + 'row' overhead)
rem         )
rem         +
rem         sum((avg_col_len) * (user_tables.num_rows - num_nulls))
rem
rem   Note: for descending columns, add one per column
rem   Note: if you use ANALYZE, you need avg_col_len + 1
rem   Note: if applied to global (partitioned) indexes, the rowid is 10 bytes
rem
 
 
prompt
prompt      From a purely arithmetic approach, this is
prompt      an estimate of how big the index is likely
prompt      to be if rebuilt with pctfree 30.
prompt
 
select
      round(
            100/70 *                -- assumed packing efficiency
            1.01 *                  -- allow for branch blocks
            (
                  ind.num_rows * (6 + uniq_ind + 4) + -- fixed row costs
                  sum(
                        (avg_col_len + desc_ind) *
                        (tab.num_rows - num_nulls)
                  )                             -- column data bytes
            ) / (8192 - 100)                    -- block size  - block overhead
      )                       index_block_estimate_70
from  (
      select      /*+ no_merge */
            num_rows, 
            decode(uniqueness,'UNIQUE',0,1)     uniq_ind
      from  user_indexes
      where index_name = 'T1_I1'
      )                       ind,
      (
      select      /*+ no_merge */
            num_rows
      from  user_tables
      where table_name = 'T1'
      )                       tab,
      (
      select      /*+ no_merge */
            column_name,
            decode(descend,'ASC',0,1)     desc_ind
      from  user_ind_columns
      where index_name = 'T1_I1'
      )                       ic,
      (
      select      /*+ no_merge */
            column_name, 
            avg_col_len, 
            num_nulls
      from  user_tab_columns
      where table_name = 'T1'
      )                       tc
where
      tc.column_name = ic.column_name
group by
      ind.num_rows,
      ind.uniq_ind
;
 
rem
rem   We know that we have just built this index at
rem   90% efficiency (pctfree 10), so let’s get an
rem   estimate of the probable size it would be at
rem   70% efficiency (pctfree 30) using a quick and
rem   dirty query.  note – on a production system,
rem   the adjusted_70 value from this query will not
rem   mean anything.
rem
 
prompt
prompt      Comparison figure – known leaf_blocks
prompt      at a known 90%, scaled to see what the
prompt      index would look like at 70%
prompt
      
select      
      leaf_blocks                   lf_actual,
      round(leaf_blocks * 90/70)    adjusted_70
from  user_indexes
where index_name = 'T1_I1'
;
 
alter index t1_i1 rebuild pctfree 30;
 
begin
      dbms_stats.gather_table_stats(
            user,
            't1',
            cascade => true,
            estimate_percent => null,
            method_opt => 'for all columns size 1'
      );
end;
/
 
prompt
prompt      Leaf blocks when rebuilt at 70% packing
prompt
 
select
      leaf_blocks
from  user_indexes
where index_name = 'T1_I1'
;
