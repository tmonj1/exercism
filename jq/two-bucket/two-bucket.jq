# fill, empty or pour water from one bucket to another recursively until reaching the
# desired state or an dead end.
def move_water_recursively(condition):
  last as $last
  | # If the same state has appeared before, don't calculate any more.
    if (.[:-1] | reduce .[] as $item (0; if $item == $last then 1 else . end) > 0) then
      empty 
    # If the starting bucke is full and the other bucket is full, don't caluculate any more.
    elif condition.startBucket == "one" and $last[0] == 0 and $last[1] == condition.bucketTwo then
      empty
    # Same as above
    elif condition.startBucket == "two" and $last[1] == 0 and $last[0] == condition.bucketOne then
      empty
    # If reached the desired state, return the result
    elif $last[0] == condition.goal or $last[1] == condition.goal then
      .
    else
      # If any conditions above isn't met, continue calculation and branching out all the possible operations.
      (. + [[0, $last[1]]] | move_water_recursively(condition)),                    # empty bucket 1
      (. + [[$last[0], 0]] | move_water_recursively(condition)),                    # empty bucket 2
      (. + [[condition.bucketOne, $last[1]]] | move_water_recursively(condition)),  # fill bucket 1
      (. + [[$last[0], condition.bucketTwo]] | move_water_recursively(condition)),  # fill bucket 2    
      (([condition.bucketOne - $last[0], $last[1]] | min) as $pour_to_1             # pour from bucket 1 to bukect 2
       | . + [[$last[0] + $pour_to_1, $last[1] - $pour_to_1]] | move_water_recursively(condition)),
      (([condition.bucketTwo - $last[1], $last[0]] | min) as $pour_to_2             # pour from bucket 1 to bukect 2
       | . + [[$last[0] - $pour_to_2, $last[1] + $pour_to_2]] | move_water_recursively(condition))
    end
;

# put aside input for later use
. as $condition

# set the initial state
| if .startBucket == "one" then
    [[0,0], [.bucketOne, 0]]  # fill bucket 1
  else # .startBucket == "two" then
    [[0,0], [0, .bucketTwo]]  # fill bucket 2    
  end

# fill, empty or pour water recursively and output results (including non-optimal ones)
| [move_water_recursively($condition)] 

# filter results and get the optimal one
| reduce .[] as $result (null; if . == null or ($result | length) < (. | length) then $result else . end)

# print output
| if . == null then
    "impossible" | halt_error
  else
    {
      "moves": (length - 1),
      "goalBucket": (if last[0] == $condition.goal then "one" else "two" end),
      "otherBucket": (if last[0] == $condition.goal then last[1] else last[0] end)
    }
  end
