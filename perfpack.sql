rem
rem	Script:		perfpack.sql
rem	Author:		J P Lewis
rem	Dated:		23-Sep-1998
rem
rem	Usage:
rem		execute performance_snapshot.{task}({time_in_seconds});
rem		execute performance_snapshot.system_events(15);
rem		execute performance_snapshot.system_events;
rem
rem		performance_snapshot.system_events
rem		performance_snapshot.session_events
rem		performance_snapshot.ts_stats
rem		performance_snapshot.file_stats
rem		performance_snapshot.filename_stats
rem		performance_snapshot.session_io
rem		performance_snapshot.system_stats
rem		performance_snapshot.roll_stats
rem		performance_snapshot.wait_stats
rem		performance_snapshot.file_waits
rem		performance_snapshot.latches
rem
rem	Notes:
rem		When run from SQL*plus, you must first issue:  
rem			set serveroutput on
rem
rem		Useful only for a single instance, but could be modified
rem		by changes to cursor c1 for multi-instance.
rem
rem		The package has to be created by SYS mainly because of 
rem		the references to the x$ objects in some procedures
rem

create or replace package performance_snapshot as
	procedure system_events (i_period in number default 10);
	procedure session_events (i_period in number default 10);
	procedure ts_stats (
				i_period in number default 10,
				i_want_names in boolean default TRUE
	);
	procedure file_stats (
				i_period in number default 10,
				i_want_names in boolean default FALSE
	);
	procedure filename_stats ( i_period in number default 10);
	procedure session_io (i_period in number default 10);
	procedure system_stats (i_period in number default 10);
	procedure roll_stats (i_period in number default 10);
	procedure wait_stats (i_period in number default 10);
	procedure file_waits (i_period in number default 10);
	procedure latches (i_period in number default 10);
end;
/


create or replace package body performance_snapshot as

/******************************************************/

procedure session_io ( i_period in number default 10) is
	cursor c1 is
		select 
			sid,
			block_gets,
			consistent_gets,
			physical_reads,
			block_changes,
			consistent_changes
		from 
			v$sess_io
		order by
			sid;
	
	type s_type is table of c1%rowtype index by binary_integer;
	s_list s_type;

begin
    if (i_period != 0) then	
	for r in c1 loop
		s_list(r.sid).block_gets := r.block_gets;
		s_list(r.sid).consistent_gets := r.consistent_gets;
		s_list(r.sid).physical_reads := r.physical_reads;
		s_list(r.sid).block_changes := r.block_changes;
		s_list(r.sid).consistent_changes := r.consistent_changes;
	end loop;
	dbms_lock.sleep (i_period);
    end if;

	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('Session I/O - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line(
		'SID' ||
		lpad('Block Gets',12) ||
		lpad('Cons gets',12) ||
		lpad('Physical',12) ||
		lpad('Block chg',12) ||
		lpad('Cons Chgs',12)
	);
	dbms_output.put_line(
		'---' ||
		lpad('----------',12) ||
		lpad('----------',12) ||
		lpad('--------',12) ||
		lpad('---------',12) ||
		lpad('----------',12)
	);
	for r in c1 loop
		if (not s_list.exists(r.sid)) then
		    s_list(r.sid).block_gets := 0;
		    s_list(r.sid).consistent_gets := 0;
		    s_list(r.sid).physical_reads := 0;
		    s_list(r.sid).block_changes := 0;
		    s_list(r.sid).consistent_changes := 0;
		end if;
		if (
		       (s_list(r.sid).block_gets != r.block_gets)
		    or (s_list(r.sid).consistent_gets != r.consistent_gets)
		    or (s_list(r.sid).physical_reads != r.physical_reads)
		    or (s_list(r.sid).block_changes != r.block_changes)
		    or (s_list(r.sid).consistent_changes != r.consistent_changes)
		) then
			dbms_output.put(to_char(r.sid,'000'));
			dbms_output.put(to_char( 
				r.block_gets - s_list(r.sid).block_gets,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.consistent_gets - s_list(r.sid).consistent_gets,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.physical_reads - s_list(r.sid).physical_reads,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.block_changes - s_list(r.sid).block_changes,
					'999,999,990')
			);
			dbms_output.put_line(to_char( 
				r.consistent_changes - s_list(r.sid).consistent_changes,
					'999,999,990')
			);
		end if;
	end loop;
end session_io;


/**********************************************************/

procedure session_events (i_period in number default 10) is
	cursor c1 is
	select 
		s.indx		indx,	
		d.kslednam	event, 
		s.kslessid	sid,
		s.ksleswts	total_waits, 
		s.kslestim	time_waited
	from
		x$ksles s,
		x$ksled d 
	where	s.kslesenm = d.indx
	order by
		s.kslessid,
		d.indx
	;
	type w_type is table of c1%rowtype index by binary_integer;
	w_list w_type;
	m_curr_sid number := 0;

begin
    if (i_period != 0) then	
	for r in c1 loop
		w_list(r.indx).event := r.event;
		w_list(r.indx).total_waits := r.total_waits;
		w_list(r.indx).time_waited := r.time_waited;
	end loop;
	dbms_lock.sleep (i_period);
    end if;
	dbms_output.put_line('----------------------------------');
	dbms_output.put_line('Session Events - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('----------------------------------');
	dbms_output.put_line(
		rpad('Event',43) ||
		lpad('Waits',12) ||
		lpad('Csec',12) ||
		lpad('Avg Csec',12)
	);
	dbms_output.put_line(
		rpad('-----',43) ||
		lpad('-----',12) ||
		lpad('----',12) ||
		lpad('--------',12)
	);
	for r in c1 loop
		if (not w_list.exists(r.indx)) then
		    w_list(r.indx).total_waits := 0;
		    w_list(r.indx).time_waited := 0;
		end if;
		if (
			   (w_list(r.indx).total_waits != r.total_waits)
			or (w_list(r.indx).time_waited != r.time_waited)
		) then
			if (m_curr_sid != r.sid) then
				dbms_output.put_line('----------');
				dbms_output.put_line(
					'SID: ' || to_char(r.sid,'9999')
				);
				dbms_output.put_line('----------');
				m_curr_sid := r.sid;
			end if;
			dbms_output.put(rpad( substr(r.event,1,43),43));
			dbms_output.put(to_char( 
				r.total_waits - w_list(r.indx).total_waits,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.time_waited - w_list(r.indx).time_waited,
					'999,999,990'));
			dbms_output.put_line(to_char( 
				(r.time_waited - w_list(r.indx).time_waited)/
				greatest(
				r.total_waits - w_list(r.indx).total_waits,
				1
				),
					'999,999.990'));
		end if;
	end loop;
end session_events;

/*********************************************************/

procedure system_events (i_period in number default 10) is
	cursor c1 is
	select 
		d.indx			indx,	
		d.kslednam		event, 
		s.ksleswts		total_waits, 
		s.kslestim		time_waited
	from
		x$kslei s,
		x$ksled d 
	where	s.indx = d.indx
	order by
		d.indx
	;
	type w_type is table of c1%rowtype index by binary_integer;
	w_list w_type;

begin
    if (i_period != 0) then	
	for r in c1 loop
		w_list(r.indx).event := r.event;
		w_list(r.indx).total_waits := r.total_waits;
		w_list(r.indx).time_waited := r.time_waited;
	end loop;
	dbms_lock.sleep (i_period);
    end if;

	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('System Events - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line(
		rpad('Event',43) ||
		lpad('Waits',12) ||
		lpad('Csec',12) ||
		lpad('Avg Csec',12)
	);
	dbms_output.put_line(
		rpad('-----',43) ||
		lpad('-----',12) ||
		lpad('----',12) ||
		lpad('--------',12)
	);
	for r in c1 loop
		if (not w_list.exists(r.indx)) then
		    w_list(r.indx).total_waits := 0;
		    w_list(r.indx).time_waited := 0;
		end if;
		if (
			   (w_list(r.indx).total_waits != r.total_waits)
			or (w_list(r.indx).time_waited != r.time_waited)
		) then
			dbms_output.put(rpad( substr(r.event,1,43),43));
			dbms_output.put(to_char( 
				r.total_waits - w_list(r.indx).total_waits,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.time_waited - w_list(r.indx).time_waited,
					'999,999,990'));
			dbms_output.put_line(to_char( 
				(r.time_waited - w_list(r.indx).time_waited)/
				greatest(
				r.total_waits - w_list(r.indx).total_waits,
				1
				),
					'999,999.990'));
		end if;
	end loop;
end system_events;

/******************************************************/

procedure ts_stats ( 
	i_period in number default 10,
	i_want_names in boolean default TRUE
) is
	cursor c1 is
		select 
			ts#,
			sum(phyrds)	phyrds,
			sum(phywrts)	phywrts,
			sum(phyblkrd)	phyblkrd,
			sum(phyblkwrt)	phyblkwrt,
			sum(readtim)	readtim,
			sum(writetim)	writetim
		from 
			v$filestat	fs,
			file$		fi
		where
			fs.file# = fi.file#
		group by
			ts#
		order by
			ts#;

	type f_type is table of c1%rowtype index by binary_integer;
	f_list f_type;
	
	cursor c2(i_ts number) is
		select 
			name
		from ts$
		where
			ts# = i_ts
		;

	r2	c2%rowtype;

begin
    if (i_period != 0) then	
	for r1 in c1 loop
		f_list(r1.ts#).phyrds := r1.phyrds;
		f_list(r1.ts#).phywrts := r1.phywrts;
		f_list(r1.ts#).phyblkrd := r1.phyblkrd;
		f_list(r1.ts#).phyblkwrt := r1.phyblkwrt;
		f_list(r1.ts#).readtim := r1.readtim;
		f_list(r1.ts#).writetim := r1.writetim;
	end loop;
	dbms_lock.sleep (i_period);
    end if;

	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('T/S Stats - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put(
		'TS#' ||
		lpad('Reads',12) ||
		lpad('Blocks',12) ||
		lpad('Avg Csecs',12) ||
		lpad('Writes',12) ||
		lpad('Blocks',12) ||
		lpad('Avg Csecs',12)
	);
	if (i_want_names) then
		dbms_output.put_line(' Tablespace');
	else
		dbms_output.new_line;
	end if;

	dbms_output.put(
		'---' ||
		lpad('-----',12) ||
		lpad('------',12) ||
		lpad('---------',12) ||
		lpad('------',12) ||
		lpad('------',12) ||
		lpad('---------',12)
	);
	if (i_want_names) then
		dbms_output.put_line(' -------------------');
	else
		dbms_output.new_line;
	end if;

	for r1 in c1 loop
		if (not f_list.exists(r1.ts#)) then
		    f_list(r1.ts#).phyrds := 0;
		    f_list(r1.ts#).phywrts := 0;
		    f_list(r1.ts#).phyblkrd := 0;
		    f_list(r1.ts#).phyblkwrt := 0;
		    f_list(r1.ts#).readtim := 0;
		    f_list(r1.ts#).writetim := 0;
		end if;
		if (
		       (f_list(r1.ts#).phyrds != r1.phyrds)
		    or (f_list(r1.ts#).phywrts != r1.phywrts)
		    or (f_list(r1.ts#).phyblkrd != r1.phyblkrd)
		    or (f_list(r1.ts#).phyblkwrt != r1.phyblkwrt)
		    or (f_list(r1.ts#).readtim != r1.readtim)
		    or (f_list(r1.ts#).writetim != r1.writetim)
		) then
			dbms_output.put(to_char(r1.ts#,'000'));
			dbms_output.put(to_char( 
				r1.phyrds - f_list(r1.ts#).phyrds,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r1.phyblkrd - f_list(r1.ts#).phyblkrd,
					'999,999,990'));
			dbms_output.put(to_char( 
				(r1.readtim - f_list(r1.ts#).readtim)/
				greatest(
					r1.phyrds - f_list(r1.ts#).phyrds,
					1
				),
					'999,999.990'));
			dbms_output.put(to_char( 
				r1.phywrts - f_list(r1.ts#).phywrts,
					'999,999,990')); 
			dbms_output.put(to_char( 
				r1.phyblkwrt - f_list(r1.ts#).phyblkwrt,
					'999,999,990'));
			dbms_output.put(to_char( 
				(r1.writetim - f_list(r1.ts#).writetim)/
				greatest(
					r1.phywrts - f_list(r1.ts#).phywrts,
					1
				),
					'999,999.990'));

			if (i_want_names) then
				open c2 (r1.ts#);
				fetch c2 into r2;
				close c2;
				dbms_output.put_line(' '|| r2.name);
			else
				dbms_output.new_line;
			end if;

		end if;
	end loop;
end ts_stats;

/******************************************************/

procedure file_stats (
	i_period in number default 10,
	i_want_names in boolean default FALSE
) is
	cursor c1 is
		select 
			file#,
			phyrds,
			phywrts,
			phyblkrd,
			phyblkwrt,
			readtim,
			writetim
		from 
			v$filestat
		order by
			file#;

	type f_type is table of c1%rowtype index by binary_integer;
	f_list f_type;
	
	cursor c2(i_file number) is
		select 
			name
		from v$datafile
		where
			file# = i_file
		;

	r2	c2%rowtype;

begin
    if (i_period != 0) then	
	for r1 in c1 loop
		f_list(r1.file#).phyrds := r1.phyrds;
		f_list(r1.file#).phywrts := r1.phywrts;
		f_list(r1.file#).phyblkrd := r1.phyblkrd;
		f_list(r1.file#).phyblkwrt := r1.phyblkwrt;
		f_list(r1.file#).readtim := r1.readtim;
		f_list(r1.file#).writetim := r1.writetim;
	end loop;
	dbms_lock.sleep (i_period);
    end if;

	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('File Stats - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put(
		'Fno' ||
		lpad('Reads',12) ||
		lpad('Blocks',12) ||
		lpad('Avg Csecs',12) ||
		lpad('Writes',12) ||
		lpad('Blocks',12) ||
		lpad('Avg Csecs',12)
	);
	if (i_want_names) then
		dbms_output.put_line(' File');
	else
		dbms_output.new_line;
	end if;

	dbms_output.put(
		'---' ||
		lpad('-----',12) ||
		lpad('------',12) ||
		lpad('---------',12) ||
		lpad('------',12) ||
		lpad('------',12) ||
		lpad('---------',12)
	);
	if (i_want_names) then
		dbms_output.put_line(' -------------------');
	else
		dbms_output.new_line;
	end if;

	for r1 in c1 loop
		if (not f_list.exists(r1.file#)) then
		    f_list(r1.file#).phyrds := 0;
		    f_list(r1.file#).phywrts := 0;
		    f_list(r1.file#).phyblkrd := 0;
		    f_list(r1.file#).phyblkwrt := 0;
		    f_list(r1.file#).readtim := 0;
		    f_list(r1.file#).writetim := 0;
		end if;
		if (
		       (f_list(r1.file#).phyrds != r1.phyrds)
		    or (f_list(r1.file#).phywrts != r1.phywrts)
		    or (f_list(r1.file#).phyblkrd != r1.phyblkrd)
		    or (f_list(r1.file#).phyblkwrt != r1.phyblkwrt)
		    or (f_list(r1.file#).readtim != r1.readtim)
		    or (f_list(r1.file#).writetim != r1.writetim)
		) then
			dbms_output.put(to_char(r1.file#,'000'));
			dbms_output.put(to_char( 
				r1.phyrds - f_list(r1.file#).phyrds,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r1.phyblkrd - f_list(r1.file#).phyblkrd,
					'999,999,990'));
			dbms_output.put(to_char( 
				(r1.readtim - f_list(r1.file#).readtim)/
				greatest(
					r1.phyrds - f_list(r1.file#).phyrds,
					1
				),
					'999,999.990'));
			dbms_output.put(to_char( 
				r1.phywrts - f_list(r1.file#).phywrts,
					'999,999,990')); 
			dbms_output.put(to_char( 
				r1.phyblkwrt - f_list(r1.file#).phyblkwrt,
					'999,999,990'));
			dbms_output.put(to_char( 
				(r1.writetim - f_list(r1.file#).writetim)/
				greatest(
					r1.phywrts - f_list(r1.file#).phywrts,
					1
				),
					'999,999.990'));

			if (i_want_names) then
				open c2 (r1.file#);
				fetch c2 into r2;
				close c2;
				dbms_output.put_line(' '|| r2.name);
			else
				dbms_output.new_line;
			end if;

		end if;
	end loop;
end file_stats;

/*******************************************************/

procedure filename_stats( i_period in number default 10) is
begin
	file_stats(
			i_period => i_period,
			i_want_names => TRUE
	);
end filename_stats;

/******************************************************/

procedure file_waits ( i_period in number default 10) is
	cursor c1 is
		select 
			indx+1		file#,
			"COUNT"		cnt,
			time
		from 
			x$kcbfwait
		where
			indx < (select count(*) from v$datafile)
		;
	
	type w_type is table of c1%rowtype index by binary_integer;
	w_list w_type;

begin
    if (i_period != 0) then	
	for r in c1 loop
		w_list(r.file#).cnt := r.cnt;
		w_list(r.file#).time := r.time;
	end loop;
	dbms_lock.sleep (i_period);
    end if;

	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('File waits - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line(
		rpad('File#',5) ||
		lpad('Count',15) ||
		lpad('Csec',15) ||
		lpad('Avg csec',15)
	);
	dbms_output.put_line(
		rpad('-----',5) ||
		lpad('-----',15) ||
		lpad('----',15)  ||
		lpad('--------',15)
	);
	for r in c1 loop
		if (not w_list.exists(r.file#)) then
		    w_list(r.file#).cnt := 0;
		    w_list(r.file#).time := 0;
		end if;
		if (
		       (w_list(r.file#).cnt != r.cnt)
		    or (w_list(r.file#).time != r.time)
		) then
			dbms_output.put(rpad(r.file#,5));
			dbms_output.put(to_char( 
				r.cnt - w_list(r.file#).cnt,
					'99,999,999,990')
			);
			dbms_output.put(to_char( 
				r.time - w_list(r.file#).time,
					'99,999,999,990')
			);
			dbms_output.put_line(to_char( 
				(r.time - w_list(r.file#).time)/
				greatest(
					r.cnt - w_list(r.file#).cnt,
					1
				),
					'99,999,999.990')
			);
		end if;
	end loop;
end file_waits;

/******************************************************/

procedure roll_stats ( i_period in number default 10) is
	cursor c1 is
		select 
			usn,
			extents,
			rssize/1024	rssize,
			hwmsize/1024	hwmsize,
			writes,
			gets,
			waits,
			shrinks,
			extends,
			aveshrink/1024	aveshrink,
			aveactive/1024	aveactive
		from 
			v$rollstat
		order by
			usn;
	
	type r_type is table of c1%rowtype index by binary_integer;
	r_list r_type;
begin
    if (i_period != 0) then	
	for r in c1 loop
		r_list(r.usn).extents := r.extents;
		r_list(r.usn).rssize := r.rssize;
		r_list(r.usn).hwmsize := r.hwmsize;
		r_list(r.usn).writes := r.writes;
		r_list(r.usn).gets := r.gets;
		r_list(r.usn).waits := r.waits;
		r_list(r.usn).shrinks := r.shrinks;
		r_list(r.usn).extends := r.extends;
		r_list(r.usn).aveshrink := r.aveshrink;
		r_list(r.usn).aveactive := r.aveactive;
	end loop;
	dbms_lock.sleep (i_period);
    end if;

	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('Rollback Stats - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line(
		'USN' ||
		lpad('Ex',4) ||
		lpad('Size K',7) ||
		lpad('HWM K',7) ||
		lpad('Writes',12) ||
		lpad('Gets',9) ||
		lpad('Waits',7) ||
		lpad('Shr',4) ||
		lpad('Grow',5) ||
		lpad('Shr K',6) ||
		lpad('Grow K',7)
	);
	dbms_output.put_line(
		'---' ||
		lpad('--',4) ||
		lpad('------',7) ||
		lpad('-----',7) ||
		lpad('------',12) ||
		lpad('----',9) ||
		lpad('-----',7) ||
		lpad('---',4) ||
		lpad('----',5) ||
		lpad('-----',6) ||
		lpad('------',7)
	);
	for r in c1 loop
		if (not r_list.exists(r.usn)) then
			r_list(r.usn).extents := 0;
			r_list(r.usn).rssize := 0;
			r_list(r.usn).hwmsize := 0;
			r_list(r.usn).writes := 0;
			r_list(r.usn).gets := 0;
			r_list(r.usn).waits := 0;
			r_list(r.usn).shrinks := 0;
			r_list(r.usn).extends := 0;
			r_list(r.usn).aveshrink := 0;
			r_list(r.usn).aveactive := 0;
		end if;
		if (
			   (r_list(r.usn).extents != r.extents)
			or (r_list(r.usn).rssize != r.rssize)
			or (r_list(r.usn).hwmsize != r.hwmsize)
			or (r_list(r.usn).writes != r.writes)
			or (r_list(r.usn).gets != r.gets)
			or (r_list(r.usn).waits != r.waits)
			or (r_list(r.usn).shrinks != r.shrinks)
			or (r_list(r.usn).extends != r.extends)
			or (r_list(r.usn).aveshrink != r.aveshrink)
			or (r_list(r.usn).aveactive != r.aveactive)
		) then
			dbms_output.put(to_char(r.usn,'000'));
			dbms_output.put(to_char( 
				r.extents - r_list(r.usn).extents,
					'990')
			);
			dbms_output.put(to_char( 
				r.rssize - r_list(r.usn).rssize,
					'999990')
			);
			dbms_output.put(to_char( 
				r.hwmsize - r_list(r.usn).hwmsize,
					'999990')
			);
			dbms_output.put(to_char( 
				r.writes - r_list(r.usn).writes,
					'99999999990')
			);
			dbms_output.put(to_char( 
				r.gets - r_list(r.usn).gets,
					'99999990')
			);
			dbms_output.put(to_char( 
				r.waits - r_list(r.usn).waits,
					'999990')
			);
			dbms_output.put(to_char( 
				r.shrinks - r_list(r.usn).shrinks,
					'990')
			);
			dbms_output.put(to_char( 
				r.extends - r_list(r.usn).extends,
					'9990')
			);
			dbms_output.put(to_char( 
				r.aveshrink - r_list(r.usn).aveshrink,
					'99990')
			);
			dbms_output.put_line(to_char( 
				r.aveactive - r_list(r.usn).aveactive,
					'999990')
			);
		end if;
	end loop;
end roll_stats;

/******************************************************/

procedure wait_stats ( i_period in number default 10) is
	cursor c1 is
	/*	Version 7 waitstat	*/
		select 
			indx,
			decode(indx,
				1, 'data block',
				2, 'sort block',
				3, 'save undo block',
				4, 'segment header',
				5, 'save undo header',
				6, 'free list',
				7, 'system undo header',
				8, 'system undo block',
				9, 'undo header',
				10, 'undo block',
				    'NEW'
			)	class,
			"COUNT"	cnt,
			time 
		from 
			x$kcbwait 
		where indx !=0
		;
	/*	Version 8.0.4 Waitstat	*/
	/*
		select 
			indx,
			decode(indx,
				1,'data block',
				2,'sort block',
				3,'save undo block', 
				4,'segment header',
				5,'save undo header',
				6,'free list',
				7,'extent map', 
				8,'bitmap block',
				9,'bitmap index block',
				10,'unused',
				11,'system undo header', 
				12,'system undo block',
				13,'undo header',
				14,'undo block',
				    'NEW'
			)	class, 
				"COUNT"	cnt,
				time 
			from x$kcbwait 
			where indx!=0
		;
	*/

	
	type w_type is table of c1%rowtype index by binary_integer;
	w_list w_type;
begin
    if (i_period != 0) then	
	for r in c1 loop
		w_list(r.indx).class := r.class;
		w_list(r.indx).cnt := r.cnt;
		w_list(r.indx).time := r.time;
	end loop;
	dbms_lock.sleep (i_period);
    end if;

	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('Wait stats - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line(
		rpad('Class',18) ||
		lpad('Count',15) ||
		lpad('Csec',15) ||
		lpad('Avg csec',15)
	);
	dbms_output.put_line(
		rpad('-----',18) ||
		lpad('-----',15) ||
		lpad('----',15)  ||
		lpad('--------',15)
	);
	for r in c1 loop
		if (not w_list.exists(r.indx)) then
		    w_list(r.indx).cnt := 0;
		    w_list(r.indx).time := 0;
		end if;
		if (
		       (w_list(r.indx).cnt != r.cnt)
		    or (w_list(r.indx).time != r.time)
		) then
			dbms_output.put(rpad(r.class,18));
			dbms_output.put(to_char( 
				r.cnt - w_list(r.indx).cnt,
					'99,999,999,990')
			);
			dbms_output.put(to_char( 
				r.time - w_list(r.indx).time,
					'99,999,999,990')
			);
			dbms_output.put_line(to_char( 
				(r.time - w_list(r.indx).time)/
				greatest(
					r.cnt - w_list(r.indx).cnt,
					1
				),
					'99,999,999.990')
			);
		end if;
	end loop;
end wait_stats;

/*********************************************************/

procedure system_stats ( i_period in number default 10) is
	cursor c1 is
		select 
			statistic#,
			name,
			value
		from 
			v$sysstat
		order by
			statistic#;
	
	type s_type is table of c1%rowtype index by binary_integer;
	s_list s_type;
begin
    if (i_period != 0) then	
	for r in c1 loop
		s_list(r.statistic#).name := r.name;
		s_list(r.statistic#).value := r.value;
	end loop;
	dbms_lock.sleep (i_period);
    end if;

	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('System stats - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line(
		rpad('Name',64) ||
		lpad('Value',15) 
	);
	dbms_output.put_line(
		rpad('----',64) ||
		lpad('-----',15) 
	);
	for r in c1 loop
		if (not s_list.exists(r.statistic#)) then
		    s_list(r.statistic#).value := 0;
		end if;
		if (
		       (s_list(r.statistic#).value != r.value)
		) then
			dbms_output.put(rpad(r.name,64));
			dbms_output.put_line(to_char( 
				r.value - s_list(r.statistic#).value,
					'99,999,999,990'));
		end if;
	end loop;
end system_stats;

/****************************************************/

procedure latches (i_period in number default 10) is

	cursor c1 is
		select 
			name,
			gets,
			misses,
			sleeps,
			immediate_gets,
			immediate_misses,
			spin_gets 
		from 
			v$latch
	;

	type w_type is table of c1%rowtype index by binary_integer;
	w_list w_type;
	v_count	number;

begin
    if (i_period != 0) then	
	v_count := 0;
	for r in c1 loop
		v_count := v_count + 1;
		w_list(v_count).name := r.name;
		w_list(v_count).gets := r.gets;
		w_list(v_count).misses := r.misses;
		w_list(v_count).sleeps := r.sleeps;
		w_list(v_count).spin_gets := r.spin_gets;
		w_list(v_count).immediate_gets := r.immediate_gets;
		w_list(v_count).immediate_misses := r.immediate_misses;
	end loop;
	dbms_lock.sleep (i_period);
    end if;

	dbms_output.put_line('---------------------------------');
	dbms_output.put_line('Latch waits - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);
	dbms_output.put_line('Interval: ' || i_period || ' seconds');
	dbms_output.put_line('---------------------------------');
	dbms_output.put_line(
		rpad('Latch',31) ||
		lpad('Gets',8) ||
		lpad('Misses',8) ||
		lpad('Sleeps',8) ||
		lpad('Sp_Get',8) ||
		lpad('Im_Gets',8) ||
		lpad('Im_Miss',8) 
	);
	dbms_output.put_line(
		rpad('-----',31) ||
		lpad('----',8) ||
		lpad('------',8) ||
		lpad('------',8) ||
		lpad('-----',8) ||
		lpad('-------',8) ||
		lpad('-------',8) 
	);

	v_count := 0;
	for r in c1 loop
		v_count := v_count + 1;
		if (not w_list.exists(v_count)) then
		    w_list(v_count).gets := 0;
		    w_list(v_count).misses := 0;
		    w_list(v_count).sleeps := 0;
		    w_list(v_count).spin_gets := 0;
		    w_list(v_count).immediate_gets := 0;
		    w_list(v_count).immediate_misses := 0;
		end if;
		if (
			   (w_list(v_count).gets != r.gets)
			or (w_list(v_count).misses != r.misses)
			or (w_list(v_count).sleeps != r.sleeps)
			or (w_list(v_count).spin_gets != r.spin_gets)
			or (w_list(v_count).immediate_gets != r.immediate_gets)
			or (w_list(v_count).immediate_misses != r.immediate_misses)
		) then
			dbms_output.put(rpad(substr(r.name,1,31),31));
			dbms_output.put(to_char( 
				r.gets - w_list(v_count).gets,
					'999,990')
			);
			dbms_output.put(to_char( 
				r.misses - w_list(v_count).misses,
					'999,990')
			);
			dbms_output.put(to_char( 
				r.sleeps - w_list(v_count).sleeps,
					'999,990')
			);
			dbms_output.put(to_char( 
				r.spin_gets - w_list(v_count).spin_gets,
					'999,990')
			);
			dbms_output.put(to_char( 
				r.immediate_gets - w_list(v_count).immediate_gets,
					'999,990')
			);
			dbms_output.put_line(to_char( 
				r.immediate_misses - w_list(v_count).immediate_misses,
					'999,990')
			);
		end if;
	end loop;

end latches;

/******************************************************/


end performance_snapshot;
/
