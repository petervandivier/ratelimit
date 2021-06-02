create table actor (
    id      serial  not null primary key,
    parent  int     not null references actor (id),
    is_root boolean not null generated always as (id=parent) stored
);