create view hierarchy_cap 
as
with recursive hierarchy as (
    select 
        a.id,
        a.parent,
        array_append('{}'::int[],a.id) as "path",
        a.is_root,
        0 as depth,
        ntc.id as ntc_id
    from node a
    left join node_type_cap ntc on ntc.node_id = a.id
    where a.is_root 
  union all 
    select 
        b.id,
        b.parent,
        array_append(a."path",b.id),
        b.is_root,
        a.depth+1,
        coalesce(ntc.id, a.ntc_id)
    from hierarchy a
    join node b on b.parent = a.id
    left join node_type_cap ntc on ntc.node_id = b.id
    where b.is_root = false
)
select 
    id,
    parent,
    "path",
    is_root,
    depth,
    ntc_id
from hierarchy;
