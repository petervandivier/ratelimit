create table node_type_cap (
    node_id int not null references node (id),
    type_id int not null references "type" (id),
    cap_id  int not null references cap (id),
    primary key (node_id, type_id, cap_id)
);