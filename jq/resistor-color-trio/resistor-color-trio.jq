def to_prefix:
  if . == 0 then
    "0 "
  else (
    {
      "0": "",
      "3": "kilo",
       "6": "mega",
       "9": "giga"
    } as $prefixTable
    | until(. % 1000 !=  0; ./1000) as $numeric
    | $prefixTable[(. / $numeric | log10 | tostring)] as $prefix
    | "\($numeric) \($prefix)"
  )
  end
;

.colors
| {
    black: 0,
    brown: 1,
    red: 2,
    orange: 3,
    yellow: 4,
    green: 5,
    blue: 6,
    violet: 7,
    grey: 8,
    white: 9
  } as $colorValues
| $colorValues[.[0]] * pow(10; $colorValues[.[2]] + 1)
  + $colorValues[.[1]] * pow(10; $colorValues[.[2]])
| to_prefix + "ohms"
| split(" ")
| {
    value: (.[0] | tonumber),
    unit: .[1]
  }