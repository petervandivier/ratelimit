

## Cap Tree

We allow for actors to be assigned no cap. In this event, they inherit the cap of their parent. actors may also be assigned a cap that exceeds that of an ancestor actor (although we assume quantities greater than an ancestor's cap should result in a rejection).

Given the following tree structure with caps of 10, 5, & 7 assigned to actors 1, 3, 7 respectively... 

```
(10) 1
     |\
     2 3    (5)
        \
         4
         | \
         6  7 (7)
```

...when we run <some query>, we see that leaf actor 4 has no cap assigned. We would like to see the parent cap for actor 3 carried down to actor 4. We would like the cap for actor 7 reflected as written in the exposed model (despite the fact that it functionally contradicts an ancestral cap).
```
+----------+--------+-----------+---------+-------+--------+----------+------+---------------+
| actor_id | parent | path      | is_root | depth | ntc_id | quantity | span | description   |
+----------+--------+-----------+---------+-------+--------+----------+------+---------------+
| 1        | 1      | {1}       | true    | 0     | 1      | 10       | 1:00 | 10 per minute |
| 3        | 1      | {1,3}     | false   | 1     | 2      | 5        | 1:00 | 5 per minute  |
| 4        | 3      | {1,3,4}   | false   | 2     | 2      | 5        | 1:00 | 5 per minute  |
| 7        | 4      | {1,3,4,7} | false   | 3     | 5      | 7        | 1:00 | 7 per minute  |
+----------+--------+-----------+---------+-------+--------+----------+------+---------------+
```

In the above table, we see the following entities...

### Root actor

`actor_id` 1 is a root & is assigned a cap for `type` 1 of 10 events per 1-minute span.

### actor_id 3

At depth 

```json
{
  "actor_id":     3,
  "parent":      1,
  "path":        [1, 3],
  "ntc_id":      2,
  "quantity":    10,
  "span":        "00:01:00",
  "description": "10 per minute"
}
```
