.instructions 

# downcase all
| map(ascii_downcase)
| . as $instructions

# save user-defined words in the $keywords object
| reduce $instructions[] as $instruction (
  {};
  # check if the instruction is a keyword definition
  ($instruction | match(": +([-+*/\\w]+) (.+) ;$") // null) as $matched
  # if so, parse and save it into the keyword object
  | if $matched != null then
      # cannot override numbers
      $matched.captures[0].string as $word
      | if ($word | test("^[-]?\\d$")) then
          "illegal operation" | halt_error
        else
          # resolve user-defined words embedded in the values, first
          (
            . as $keywords
            | $matched.captures[1].string
            | split(" ")
            | map(($keywords[.] // [.]) | .[])
          ) as $value
          # then store the word/value pair
          | .[$word] = $value
        end
    else
      .
    end
)
| . as $keywords

# filter out user-defined instructions
| $instructions
| map(select(test(": +[-+*/\\w]+ .+ ;$") | not))

# tokenize and resolve user-defined words
| .[]
| split(" ")
| map(
    if $keywords[.] != null then
      $keywords[.] | .[]
    else
      .
    end
)

# type conversion
| map(
    if test("\\d") then
      tonumber
    else
      .
    end
  )

# stack manipulation (dup, drop, swap and over)
| reduce .[] as $token (
    [];
    if $token == "dup" then
      if . == [] then "empty stack" | halt_error else  . + [.[-1]] end
    elif $token == "drop" then
      if . == [] then "empty stack" | halt_error else .[:-1] end
    elif $token == "swap" then
      if . == [] then
        "empty stack" | halt_error
      elif .[:-1] == [] then
        "only one value on the stack" | halt_error
      else
        .[:-2] + [.[-1], .[-2]]
      end
    elif $token == "over" then
      if . == [] then
        "empty stack" | halt_error
      elif .[:-1] == [] then
        "only one value on the stack" | halt_error
      else
        . + [.[-2]]
      end
    elif ($token | type) == "string" and ($token| test("\\w")) then
      # unknown operations
      "undefined operation" | halt_error
    else # numbers
      . + [$token]
    end
  )

# arithmetic calculation (+, -, *, /)
| reduce .[] as $token (
    [];
    #(. as $o | $token | debug | $o) |
    if (($token | type) == "number") then
      . += [$token]
    elif ($token | test("[-+*/]")) then
      .[-2] as $v1
      #| (. as $o | $v1 | debug | $o)
      | .[-1] as $v2
      #| (. as $o | $v2 | debug | $o)
      | if . == [] then
          "empty stack" | halt_error
        elif .[:-1] == [] then
          "only one value on the stack" | halt_error
        elif ((. | length) >= 2 and ($v1 | type) == "number" and ($v2 | type) == "number") then
          [
            if $token == "+" then
              $v1 + $v2
            elif $token == "-" then
              $v1 - $v2
            elif $token == "*" then
              $v1 * $v2
            else # "/"
              if $v2 == 0 then
                "divide by zero" | halt_error
              else
                $v1 / $v2 | floor
              end
            end
          ] + .[:-2]
        else
          "error: two numbers are required for an arithmetic operator" | halt_error
        end
    else
      . += [$token]
    end
  )