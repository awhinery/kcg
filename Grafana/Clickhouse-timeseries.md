# Time series in clickhouse require some artifice and forethought. 

### Using a table of SNMP readings from ifHCInOctets, for example:


> SELECT Time, runningDifference(ifHCInOctets)*8/300 AS in <BR>
> FROM <BR>
> ( <BR>
> SELECT <BR> 
>  Time, <BR>
>  ifHCInOctets <BR>
>  FROM <BR>
>     snmp.int_count <BR>
>     WHERE <BR>
>         $__timeFilter(Time) <BR>
>         AND <BR>
>         toString(RouterID) = '${exporter}'  AND Interface = ${interface} <BR>
>        ORDER BY Time ASC <BR>
> ) <BR>
  
  The inner subquery produces a constant series of rows so that runningDifference() can refer to a previous row.
  If you don't do this, Clickhouse will return blocks of rows, and the first line of a block cannot refer to the last line of the previous block. 
  
### intervals and grouping. 

If you are looking at a table such as flows_raw (see schema in the ../Clickchouse folder), you can use toStartOfInterval() to group returned rows into a sum():

> SELECT <BR>
  > <B>toStartOfInterval(TimeFlowStart, INTERVAL 300 SECOND) as i</B>, <BR>
> sum(Bytes)*8/300 as In <BR>
> FROM flows_raw  <BR>
> WHERE dispIPv4(SamplerAddress) = '${exporter}' AND $__timeFilter(TimeFlowStart) <BR>
> AND InIf = ${interface} <BR>
  > <B>GROUP BY i</B> <BR>
> ORDER BY i ASC <BR>


