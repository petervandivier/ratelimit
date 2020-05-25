select * 
from event
where node_id = 7;


-- agg sum over timeframe
-- node filtering must happen in CTE else OR NULL predicate is needed on LEFT JOIN
-- do we want a windowed derived view for arbitrary c.time bounds?
with filtered_event as (
    select *
    from event
    where node_id = 7
)
select c."timestamp", e.node_id, sum(e.quantity)
from calendar c
left outer join filtered_event e
    on e."timestamp" >= c."timestamp"
    and e."timestamp" < c."timestamp" + '1 minute'::interval
where  c."timestamp" between '2020-03-08 22:28' and '2020-03-08 22:35'
group by c."timestamp", e.node_id;

-- agg sum over arbitrary time frame
with filtered_event as (
    select *
    from event
    where node_id = 7
)
select 
    cw.start_timestamp, 
    cw.end_timestamp, 
    e.node_id,
    sum(e.quantity)
from calendar_window(
    '2020-03-08 22:30',
    '2020-03-08 22:33',
    '30 seconds'
) cw
left join filtered_event e
    on e."timestamp" >= cw.start_timestamp
    and e."timestamp" < cw.end_timestamp
group by 
    cw.start_timestamp, 
    cw.end_timestamp, 
    e.node_id
order by 1;



