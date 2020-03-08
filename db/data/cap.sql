insert into cap
(id, quantity, span,                 "description",  type_label)
values
(1,  5,        '1 minute'::interval, '5 per minute',  'ratelimit'),
(2,  100,      '1 day'::interval,    '100 per day',   'quota'),
(3,  10,       '1 minute'::interval, '10 per minute', 'ratelimit');
