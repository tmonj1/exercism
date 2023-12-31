. as $o
| if .series == "" then
    "series cannot be empty" | halt_error
  else
    .
  end
| if .sliceLength > 0 then
    [range((.series | length) - .sliceLength + 1)] // []
  elif .sliceLength == 0 then
    "slice length cannot be zero" | halt_error
  else
    "slice length cannot be negative" | halt_error
  end
| map($o.series[.:.+$o.sliceLength])
| if . == [] then 
    "slice length cannot be greater than series length" | halt_error
  else . end