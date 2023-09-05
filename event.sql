set linesize 130
set pagesize 50
select inst_id, event, count(*), max(seconds_in_wait), min(sid), max(sid)
from gv$session
where state = 'WAITING'
--and program like '%LMS%'
and event not in (
'gcs remote message',
'DIAG idle wait',
'PX Deq: Execute Reply',
'ges remote message',
'pipe get',
'pmon timer',
'rdbms ipc message',
'smon timer',
'PX Deq: Execution Msg',
'SQL*Net message from client',
'Streams AQ: qmn slave idle wait',
'Streams AQ: qmn coordinator idle wait',
'Streams AQ: waiting for messages in the queue',
'Streams AQ: waiting for time management or cleanup tasks',
'PL/SQL lock timer'
)
group by inst_id, event
order by inst_id, event
/
