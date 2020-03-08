create table cap (
    id            serial   not null primary key,
    quantity      int      not null,
    span          interval not null,
    "description" text,
    type_label    text     not null,
    check (type_label in ('ratelimit','quota'))
);

comment on column cap.quantity is 'static rate of events/minute';
comment on column cap.span     is 'time interval over which quantity is to be enforced';
