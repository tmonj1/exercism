def steps(depth):
  if . == 1 then
    depth
  else
    if . % 2 == 0 then
      . / 2 | steps(depth + 1)
    else
      . * 3 + 1 | steps(depth + 1)
    end
  end;

def steps:
  if . < 1 then 
    "Only positive integers are allowed" | halt_error
  else
    steps(0)
  end;
