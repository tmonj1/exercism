def encode:
  . as $input
  | if $input == "" then 
      "" else
    (. | length) as $len
    | 1
    | [while($input[0:1] == $input[.:.+1]; .+1)]
    | length + 1
    | (if . == 1 then "" else "\(.)" end) as $num_part
    | if . < $len then
        "\($num_part)\($input[0:1])" + ($input[.:] | encode)
      else
        "\($num_part)\($input[0:1])" 
      end
    end
;

def decode:
  . as $input
  | match("^[[:digit:]]*[[:alpha:] ]")
  | (
      if (.string[0:1] | test("\\d")) then 
        (.string[0:.length-1] | tonumber)
       else
         1
       end
    ) as $count
  | .string[.length - 1:.length] as $char
  | if .length < ($input | length) then
      $char * $count + ($input[.length:] | decode)
    else
      $char * $count
    end
;
