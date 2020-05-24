
with recursive dates as (
    select '2020-03-08 22:00'::timestamp as tstz
    union all 
    select d.tstz + '1 minute'::interval
    from dates d
    where d.tstz < ('2020-03-08 22:00'::timestamp + '1 hour'::interval)
)
insert into calendar (epoch)
select extract(epoch from tstz)
from dates;
