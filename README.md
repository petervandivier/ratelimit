

## Cap Tree

We allow for nodes to be assigned no cap. In this event, they inherit the cap of their parent. Nodes may also be assigned a cap that exceeds that of an ancestor node (although we assume quantities greater than an ancestor's cap should result in a rejection).

Given the following tree structure with caps of 10, 5, & 7 assigned to nodes 1, 3, 7 respectively... 

```
(10) 1
     |\
     2 3    (5)
        \
         4
         | \
         6  7 (7)
```

...when we run the following query, we see that leaf node 4 has no cap assigned. We would like to see the parent cap for node 3 carried down to node 4. We would like the cap for node 7 reflected as written in the exposed model (despite the fact that it functionally contradicts an ancestral cap).

```sql
drop table if exists cap_hierarchy;

select 
    hc.id as node_id, 
    hc.parent, 
    hc."path",
    hc.is_root,
    hc."depth",
    hc.ntc_id,
    c.quantity,
    c.span,
    c."description"
into temp cap_hierarchy
from hierarchy_cap hc
join node_type_cap ntc on ntc.id = hc.ntc_id
join cap c on c.id = ntc.cap_id
where hc.id in (
    select unnest("path") 
    from hierarchy_cap
    where id = 7
);

select * 
from cap_hierarchy
order by parent, id;
```

The `node_type_cap` join here will be used later to filter out caps for event `type`s we don't care about. Note that a single node can have multiple caps for the same event `type`. 

```
+---------+--------+-----------+---------+-------+--------+----------+------+---------------+
| node_id | parent | path      | is_root | depth | ntc_id | quantity | span | description   |
+---------+--------+-----------+---------+-------+--------+----------+------+---------------+
| 1       | 1      | {1}       | true    | 0     | 1      | 10       | 1:00 | 10 per minute |
| 3       | 1      | {1,3}     | false   | 1     | 2      | 5        | 1:00 | 5 per minute  |
| 4       | 3      | {1,3,4}   | false   | 2     | 2      | 5        | 1:00 | 5 per minute  |
| 7       | 4      | {1,3,4,7} | false   | 3     | 5      | 7        | 1:00 | 7 per minute  |
+---------+--------+-----------+---------+-------+--------+----------+------+---------------+
```

In the above table, we see the following entities...

### Root Node

`node_id` 1 is pretty self-explanatory. It is assigned a cap for `type` 1 of 10 events per 1-minute span.

### node_id 3

At depth 

```json
{
  "node_id":     3,
  "parent":      1,
  "path":        "{1,3}",
  "ntc_id":      2,
  "quantity":    10,
  "span":        "00:01:00",
  "description": "10 per minute"
}
```

## Time Bounds

We can retrieve relevant span evaluation length for a give node-type cap and cache it in a temp table with the following query

```sql
drop table if exists time_bound;

with recursive time_bound as (
    select 
       max("timestamp") as ts,
       ntc.cap_id,
       0 as depth
    from "event" as e
    left join node_type_cap ntc 
        on ntc.node_id = e.node_id
        and ntc.type_id = e.type_id
    left join cap c on c.id = ntc.cap_id
    where e.node_id = 1 
      and e.type_id = 1
    group by ntc.cap_id
  union all
    select 
        tb.ts - c.span,
        tb.cap_id,
        tb.depth + 1 as depth
    from time_bound as tb
    left join cap c on c.id = tb.cap_id
    where depth < 4
)
select 
    tb.ts as ts_start,
    lag(tb.ts,1) over (order by tb.depth) as ts_end,
    tb.depth,
    ntc.id as ntc_id,
    1 as node_id,
    1 as type_id,
    tb.cap_id
into temp time_bound
from time_bound tb
join node_type_cap ntc 
  on ntc.node_id = 1
 and ntc.type_id = 1
 and ntc.cap_id = tb.cap_id; 

select * 
from time_bound
where ts_end is not null;
```
...which for our example looks like this.

```
+------------------------+--------+-------+------------------------+
| ts_start               | cap_id | depth | ts_end                 |
+------------------------+--------+-------+------------------------+
| 2020-03-08 22:31:00+00 | 3      | 1     | 2020-03-08 22:32:00+00 |
| 2020-03-08 22:30:00+00 | 3      | 2     | 2020-03-08 22:31:00+00 |
| 2020-03-08 22:29:00+00 | 3      | 3     | 2020-03-08 22:30:00+00 |
| 2020-03-08 22:28:00+00 | 3      | 4     | 2020-03-08 22:29:00+00 |
+------------------------+--------+-------+------------------------+
```

These are the relevant time bounds to evaluate cap id 1 for event type 1 against node 1. In order to complete the evaluation, we need to sum the quantity of all available events for each time bound start & end period.

Our previous evalution of `cap` tree used a bottom-up search to list all parent nodes & caps that a leaf node is bound by. To evaluate the throttling status of a parent node, we need to use a top-down search to enumerate all children for whom the parent is responsible. We use the `node.id` of all descendants to retrieve all relevant events (by `type_id`) from the `"event"` table. We can enumerate these descendants by flipping the `WHERE` clause from our inital `cap_hierarchy` query like so...

```sql
where 1 in (
    select unnest("path") 
    from hierarchy_cap sub
    where sub.id = hc.id
)
```

This is getting messy but I'm moving fast so bear with me. We join the `time_bound` & `cap_hierarchy` sets together like so...

```sql
drop table if exists time_bound_caps;

select 
   tb.ts_start, 
   tb.ts_end,
   tb.depth as period_num,
   tb.ntc_id,
   ct.id as node_id,
   ct."path",
   ct."depth",
   ct.quantity,
   ct.span,
   ct."description"
into temp time_bound_caps
from time_bound tb
join cap_hierarchy ct on ct.ntc_id = tb.ntc_id
where ts_end is not null;

select * 
from time_bound_caps;
```
