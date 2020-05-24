
create or replace function calendar_window (
    _start_timestamp timestamptz,
    _end_timestamp   timestamptz,
    _interval        interval    default '1 minute'::interval
) 
returns table (
    start_timestamp timestamptz,
    end_timestamp   timestamptz
)
language sql immutable
as
$$
    with recursive dates as (
        select 
            _start_timestamp as "start_timestamp",
            _start_timestamp + _interval as "end_timestamp"
        union all 
        select 
            d."end_timestamp",
            d."end_timestamp" + _interval
        from dates d
        where d."end_timestamp" <= _end_timestamp
    )
    select 
        start_timestamp,
        end_timestamp
    from dates;
$$;
