if (.strand1 | length) != (.strand2 | length) then
  "strands must be of equal length" | halt_error(1)
else
  (.strand1 | split("")) as $s1
  | (.strand2 | split("")) as $s2
  | .strand1
  | split("")
  | [range(length)]
  | reduce .[] as $i (0; 
    if $s1[$i] != $s2[$i] then
      . + 1
    else
      .
    end)
end