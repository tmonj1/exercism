def count_egg:
  (. / 2 | floor) as $number
  | if $number <= 0 then
      . % 2
    else
      (. % 2) + ($number | count_egg)
    end
;

.number | count_egg