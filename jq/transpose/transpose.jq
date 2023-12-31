.lines
| [
    foreach reverse[] as $row (
      0;
      . = ([($row | length), .] | max);
      $row + " " * ([. - ($row | length), 0] | max)
      )
  ]
| reverse
| map(split(""))
| transpose
| map(join(""))