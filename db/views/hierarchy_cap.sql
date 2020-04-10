create view ntc_inheritance 
as
with recursive ntc_inheritance as (
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
    from ntc_inheritance a
    join node b on b.parent = a.id
    left join node_type_cap ntc on ntc.node_id = b.id
    where b.is_root = false
)
select 
    ni.id as node_id,
    ni.parent,
    ni."path",
    ni.is_root,
    ni.depth,
    ni.ntc_id,
-- TODO: add inherited_from attribute for multiple tiers of skips?
    ni.id != ntc.node_id as is_inherited,
    ntc.type_id,
    ntc.event_id
from ntc_inheritance ni
join node_type_cap ntc on ntc.id = ni.ntc_id;
