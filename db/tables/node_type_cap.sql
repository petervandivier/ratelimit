create table node_type_cap (
    id      serial not null primary key,
    node_id int not null references node (id),
    type_id int not null references "type" (id),
    cap_id  int not null references cap (id),
-- ¿it doesn't make sense to allow multiple caps per node-type, right?
    unique (node_id, type_id) 
);