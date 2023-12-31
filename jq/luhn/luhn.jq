split("")
| map(if test("\\d") then . elif . == " " then empty else ("false" | halt_error(0)) end)
| if length <= 1 then (false | halt_error(0)) else . end
| reverse
| . as $digits
| [range(length)]
| reduce .[] as $d (
    0;
    . += (($digits[$d] | tonumber) * ($d % 2 + 1) | (. % 10) + (. / 10 | floor))
  )
| . % 10 == 0