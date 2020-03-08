
Given the following tree structure with caps of 10 & 5 assigned to nodes 1 & 3 respectively... 

```
(10) 1
     |\
     2 3    (5)
        \
         4
```

...when we run the following query, we see that leaf node 4 has no cap assigned. We would like to see the parent cap for node 3 carried down to node 4.

```sql
select 
    h.id,
	h.parent,
	h.path,
	h.is_root,
	h.depth,
	ntc.node_id,
	c.quantity,
	c.span,
	c."description",
	c.type_label
from hierarchy h 
left join node_type_cap ntc on ntc.node_id = h.id
left join cap c on c.id = ntc.cap_id
where h.id in (
	select unnest("path") 
	from hierarchy 
	where id = 4
)
order by h.parent, h.id;
```
