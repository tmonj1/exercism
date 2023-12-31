[
  "black",
  "brown",
  "red",
  "orange",
  "yellow",
  "green",
  "blue",
  "violet",
  "grey",
  "white"
] as $colorTable
| .colors[0:2]
| reduce .[] as $c (""; . + ($colorTable | index($c) | tostring))
| sub("^0"; "")