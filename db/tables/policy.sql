create table "policy" (
    id      serial not null primary key,
    actor_id int not null references actor (id),
    type_id int not null references "type" (id),
    cap_id  int not null references cap (id),
-- ¿it doesn't make sense to allow multiple caps per actor-type, right?
-- right... i want to allow multiple caps with different labels & evaluate
-- per unique `cap.span`. 🤔 think i need to fix the normalization here
    unique (actor_id, type_id, cap_id) 
);