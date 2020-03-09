


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

...when we run the following query, we see that leaf node 4 has no cap assigned. We would like to see the parent cap for node 3 carried down to node 4. We would like the cap for node 7 reflected as written in the exposed model (despite the fact that it's functionally invalid).

```sql
drop table if exists cap_tree;

select 
    hc.id, 
    hc.parent, 
    hc."path",
    hc.is_root,
    hc."depth",
    hc.ntc_id,
    c.quantity,
    c.span,
    c."description"
into temp cap_tree
from hierarchy_cap hc
join node_type_cap ntc on ntc.id = hc.ntc_id
join cap c on c.id = ntc.cap_id
where hc.id in (
    select unnest("path") 
    from hierarchy_cap
    where id = 7
);

select * 
from cap_tree
order by parent, id;
```

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
    tb.cap_id,
    tb.depth,
    lag(tb.ts,1) over (order by tb.depth) as ts_end
into temp time_bound
from time_bound tb;

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

Our previous evalution of `cap` tree used a bottom-up search to list all parent nodes & caps that a leaf node is bound by. To evaluate the throttling status of a parent node, we need to use a top-down search to enumerate all children for whom the parent is responsible. We use the `node.id` of all descendants to retrieve all relevant events (by `type_id`) from the `"event"` table. We can enumerate these descendants by flipping the `WHERE` clause from our inital `cap_tree` query like so...

```sql
where 1 in (
    select unnest("path") 
    from hierarchy_cap sub
    where sub.id = hc.id
)
```


