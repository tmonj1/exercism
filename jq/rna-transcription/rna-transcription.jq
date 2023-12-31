def toRna:
  split("") 
  | map(
      if . == "G" then
        "C"
      elif . == "C" then
        "G"
      elif . == "T" then
        "A"
      else # "A"
        "U"
      end
    )
  | join("")
;
