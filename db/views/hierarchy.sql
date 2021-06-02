create view hierarchy 
as
with recursive hierarchy as (
    select 
        a.id,
        a.parent,
        array_append('{}'::int[],a.id) as "path",
        a.is_root,
        0 as depth
    from actor a
    where a.is_root 
  union all 
    select 
        b.id,
        b.parent,
        array_append(a."path",b.id),
        b.is_root,
        a.depth+1 
    from hierarchy a
    join actor b on b.parent = a.id
    where b.is_root = false
)
select 
    id,
    parent,
    "path",
    is_root,
    depth
from hierarchy;
