. as $n |

if $n.number % 3 == 0 then
  "Pling"
else
  ""
end | 
if $n.number % 5 == 0 then
  . + "Plang"
else
  .
end | 
if $n.number % 7 == 0 then
  . + "Plong"
else
  .
end | 
if $n.number % 3 != 0 and $n.number % 5 != 0 and $n.number % 7 != 0 then
  $n.number
else
  .
end



