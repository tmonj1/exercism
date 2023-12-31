def next_prime:
  if . == 2 then
    3
  else 
    . as $prev_prime
    | [2, 99999999999, . + 2]
    | until(
        .[0] > .[1];
        if (.[2] % .[0] == 0) then
          [2, 99999999999, .[2] + 2]
        else
          [.[0] + 1, (.[2] / .[0] | floor), .[2]]
        end
      )
    | .[2]
  end
;

if $n == 0 then
  "there is no zeroth prime" | halt_error
else
  [$n, 2] | until(.[0] <= 1; [.[0] - 1, (.[1] | next_prime)]) | .[1]
end