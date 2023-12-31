.strings
| if . != [] then
    (
      [., .[1:] + [first]]
      | transpose
      | .[-1] as $last
      | .[:-1]
      | reduce .[] as $pair ([]; . + ["For want of a \($pair[0]) the \($pair[1]) was lost." ])
      | . + ["And all for the want of a \($last[1])."]
    )
  else
    []
  end