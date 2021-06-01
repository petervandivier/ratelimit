
create table "event" (
    id          bigserial not null primary key,
    actor_id     int       not null references actor (id),
    quantity    int       not null,
    type_id     int       not null references "type" (id),
    "timestamp" timestamp with time zone not null default now()
);
