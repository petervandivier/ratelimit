create table "type" (
    id     serial       not null primary key,
    "name" varchar(100) not null unique
);
