create table "policy" (
    id      serial not null primary key,
    actor_id int not null references actor (id),
    event_type_id int not null references event_type (id),
    rate_id  int not null references rate (id),
    unique (actor_id, event_type_id, rate_id) 
);