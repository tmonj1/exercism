.x * .x + .y * .y
| sqrt
| if . > 10 then
    0
  elif . > 5 then
    1
  elif . > 1 then
    5
  else # . <= 1
    10
  end
    