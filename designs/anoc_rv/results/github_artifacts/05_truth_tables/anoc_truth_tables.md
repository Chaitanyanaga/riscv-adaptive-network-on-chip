# ANOC-RV Truth Tables

## ANOC Router

| Condition | Route |
|---|---|
| dst = current | LOCAL |
| dst_x > current_x | EAST |
| dst_x < current_x | WEST |
| dst_x = current_x and dst_y > current_y | NORTH |
| dst_x = current_x and dst_y < current_y | SOUTH |

## Even-Odd Router

| Condition | Route |
|---|---|
| src = dst | LOCAL |
| src_x < dst_x | EAST |
| src_x > dst_x | WEST |
| src_x = dst_x and src_y < dst_y | NORTH |
| src_x = dst_x and src_y > dst_y | SOUTH |

## Priority Arbiter

| Request condition | Result |
|---|---|
| No request | No grant |
| One requester | That requester granted |
| Multiple requesters | Highest priority granted |
| Equal priority | Lowest input index wins |
