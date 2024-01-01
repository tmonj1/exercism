def pour(c):
  last as $last
  | if (.[:-1] | reduce .[] as $item (0; if $item == $last then 1 else . end) > 0) then
      empty 
    elif c.startBucket == "one" and $last[0] == 0 and $last[1] == c.bucketTwo then
      empty
    elif c.startBucket == "two" and $last[1] == 0 and $last[0] == c.bucketOne then
      empty
    elif $last[0] == c.goal or $last[1] == c.goal then
      .
    else
      (. + [[0, $last[1]]] | pour(c)),
      (. + [[$last[0], 0]] | pour(c)),
      (. + [[c.bucketOne, $last[1]]] | pour(c)),
      (. + [[$last[0], c.bucketTwo]] | pour(c)),
      (([c.bucketOne - $last[0], $last[1]] | min) as $pour_to_1
       | . + [[$last[0] + $pour_to_1, $last[1] - $pour_to_1]] | pour(c)),
      (([c.bucketTwo - $last[1], $last[0]] | min) as $pour_to_2
       | . + [[$last[0] - $pour_to_2, $last[1] + $pour_to_2]] | pour(c))
    end
;

. as $c
| if .startBucket == "one" then [[.bucketOne, 0]] else [[0, .bucketTwo]] end
| [pour($c)] 
| reduce .[] as $r (null; if . == null or ($r | length) < (. | length) then $r else . end)
| if . == null then
    "impossible" | halt_error
  else
    {
      "moves": length,
      "goalBucket": (if last[0] == $c.goal then "one" else "two" end),
      "otherBucket": (if last[0] == $c.goal then last[1] else last[0] end)
    }
  end
