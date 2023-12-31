.heyBob
| gsub(" +$"; "")
| endswith("?") as $question 
| (gsub("[\\W\\d]"; "") | test("^[A-Z]+$")) as $yell 
| test("^\\s*$") as $silence 
| if $question then
    if $yell then 
      "Calm down, I know what I'm doing!"
    else
      "Sure."
    end
  elif $yell then
    "Whoa, chill out!"
  elif $silence then
    "Fine. Be that way!" 
  else
    "Whatever."
  end