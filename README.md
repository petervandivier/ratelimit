
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
select 
    hc.id, 
    hc.parent, 
    hc."path",
    hc.is_root,
    hc."depth",
    hc.ntc_id,
    c.*
from hierarchy_cap hc
join node_type_cap ntc on ntc.id = hc.ntc_id
join cap c on c.id = ntc.cap_id
where hc.id in (
    select unnest("path") 
    from hierarchy_cap
    where id = 7
)
order by hc.parent, hc.id;
```
