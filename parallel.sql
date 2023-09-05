---------------------------------------------------------------------------------------
-- Script        : parallel.sql
-- Author        : Seo, kang-gyo
-- Creation date : 2004.01.01
-- Description   : Parallel 贸府登绰 技记甸俊 措茄 tree 备己
---------------------------------------------------------------------------------------
set linesize 300
col sid_serial  heading "SID,Serial#"  format a12
col class    format a5
col status   format a1
col spid     format a8
col module   format a15
col module   format a20
col program  format a15
col wait     format a30
col last_call_et  heading "LCE" format  999999
col machine  format a10
col terminal format a10
col osuser   format a10
col sql_text format a60
col in_wait new_v in_wait
col server_num   format 99999
col degree       format 999
col qcsid        format 99999
SELECT  lpad(nvl(to_char(ps.server#),'Main'),5,' ')    class
       ,ps.sid||', '||ps.serial#        as sid_serial
       ,ps.qcsid
       ,ps.degree          
       ,substr(s.status,1,1)            as status            
       ,p.spid                             spid        
       ,decode(substr(s.action,1,4),'FRM:',substr(s.module,1,15)||'(Form)','Onli',substr(s.module,1,15)||'(Form)','Conc',substr(s.module,1,15)||'(Conc)',substr(s.module,1,20) )  as MODULE
       ,substr(s.program,-6,6)              program
       ,substr(sw.event,1,30)              wait
       ,last_call_et                       last_call_et
       ,(select substr(sql_text,1,50) from v$sql sq
          where sq.address    = s.sql_address 
            and sq.hash_value = s.sql_hash_value
            and rownum = 1)                sql_text
       ,nvl(ps.server#,0)               as server_num  
FROM    v$session         s                              
       ,v$process         p                                  
       ,v$session_wait    sw 
       ,v$px_session      ps
WHERE  s.paddr           = p.addr                            
AND    sw.sid            = s.sid  
AND    s.sid             = ps.sid
AND    s.serial#         = ps.serial#
AND    not exists( select 1
                   from   v$bgprocess bp
                   where  p.addr           = bp.paddr    )              
order by
       ps.qcsid
      ,degree                    nulls first
      ,substr(s.program,-6,6)    nulls first
      ,class         
/
