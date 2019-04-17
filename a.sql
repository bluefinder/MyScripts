--
-- A.SQL
-- 내  용 : ACTIVE SESSION 정보 표시(11g 이상)
-- 작성자 : 신상준
-- 작성일 : 2016. 4.
--
COL "MODULE"   FORMAT A20
COL "ACTION"            FORMAT A20
COL "STATUS"            FORMAT A11
COL "SID"               FORMAT 99999
COL "SERIAL#"          FORMAT 999999
COL "SEQ#"   FORMAT 9999
col last_call_et  heading "LCE" format  999999
COL "SQL_EXEC_START"   FORMAT A9
COL "CPU_THIS_CAL"   FORMAT 9999
COL "SEQ#"   FORMAT 9999
COL "SEQ#"   FORMAT 9999
COL "SEQ#"   FORMAT 9999
COL "SQL_ID"            FORMAT A14
COL "OSPROGRAM"         FORMAT A11
COL "ACTION"            FORMAT A11
COL SQL   HEADING "SQL|L/P/BC/CC"FORMAT A40
COL EVENT  FORMAT A31

SET PAGESIZE 10000 
SET LINESIZE 200
SET FEED ON
SET HEAD ON
SET TERMOUT ON
SELECT  substr(S.MODULE,1,19) MODULE,
--       S.ACTION,
       S.STATUS,
       S.SID,
--       S.SERIAL# ,
--       SEQ#,
       LAST_CALL_ET ,
       substr(S.EVENT,1,30) EVENT ,
       S.SQL_ID ,
--       S.SQL_EXEC_START,
--       STAT.CPU - STAT.CPU_THIS_CALL_START CPU_THIS_CALL,
--       STAT.CPU,
--       STAT.UGA_MEMORY,
--       STAT.PGA_MEMORY,
       STAT.COMMITS CMTs,
       STAT.ROLLBACKS ROLL,
       SI.BLOCK_GETS BLK_GET,
       SI.CONSISTENT_GETS CON_GET,
       SI.PHYSICAL_READS PHY_READ,
       SI.BLOCK_CHANGES BLK_CH,
       SI.CONSISTENT_CHANGES CON_CH,
--       P.PROGRAM "OSPROGRAM",
       P.SPID,
       P.PID
  FROM V$SESSION S,
       V$SESS_IO si,
       V$PROCESS p,
       (SELECT DISTINCT SID,
               SERIAL#,
               AUTHENTICATION_TYPE,
               CLIENT_CHARSET,
               CLIENT_VERSION
          FROM V$SESSION_CONNECT_INFO) SCI,
       (select ss.sid stat_sid,
               sum(decode(sn.name, 'CPU used when call started', ss.value, 0)) CPU_this_call_start,
               sum(decode(sn.name, 'CPU used by this session', ss.value, 0)) CPU,
               sum(decode(sn.name, 'session uga memory', ss.value, 0)) uga_memory,
               sum(decode(sn.name, 'session pga memory', ss.value, 0)) pga_memory,
               sum(decode(sn.name, 'user commits', ss.value, 0)) commits,
               sum(decode(sn.name, 'user rollbacks', ss.value, 0)) rollbacks
          from v$sesstat ss,
               v$statname sn
         where ss.STATISTIC# = sn.STATISTIC#
           and (sn.name = 'CPU used when call started'
                    or sn.name = 'CPU used by this session'
                    or sn.name = 'session uga memory'
                    or sn.name = 'session pga memory'
                    or sn.name = 'user commits'
                    or sn.name = 'user rollbacks')
         group by ss.sid) stat
 WHERE ( s.STATUS = 'ACTIVE' )
   AND ( (s.USERNAME is not null)
           and (NVL(s.osuser, 'x') <> 'SYSTEM')
           and (s.type <> 'BACKGROUND') )
   and si.sid(+) = s.sid
   and p.addr(+) = s.paddr
   and stat.stat_sid = s.sid
   and sci.sid (+) = s.sid
   and sci.serial# (+) = s.serial#
 --  and s.LAST_CALL_ET > 3600*2
   and event not in ( 'PL/SQL lock timer' ,'pipe get')
   and event not like 'Streams AQ%'
--   and action not in ('Concurrent Request')
--and ( ACTION like 'FRM%' or  ACTION like 'FRM%' )
 order by s.LAST_CALL_ET desc
/
