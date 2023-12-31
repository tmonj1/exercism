.legacy
| to_entries 
| map(
    .key as $point
    | reduce .value[] as $letter (
        [];
        . + [
          {
            key: ($letter | ascii_downcase),
            value:($point | tonumber)
          }
        ]
      )
  )
| add
| from_entries