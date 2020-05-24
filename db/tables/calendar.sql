
create table calendar ( 
    epoch bigint not null primary key,
    "timestamp" timestamptz generated always as (to_timestamp(epoch)) stored
);
