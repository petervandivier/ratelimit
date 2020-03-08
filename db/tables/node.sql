create table node (
    id      serial  not null primary key,
    parent  int     not null references node (id),
    is_root boolean not null generated always as (id=parent) stored
);