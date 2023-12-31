def atbash_encode:
  ascii_downcase
  | gsub("[^\\w\\d]"; "")
  | split("")
  | map(
      if test("[a-z]") then
        (explode[] | [219 - .] | implode)
      else
        . 
      end
    )
  | join("")
  | gsub("(?<x>.{5})"; "\(.x) ")
  | gsub(" $"; "")
;

def atbash_decode:
  split("")
  | map(
      if test("[a-z]") then
        (explode[] | [219 - .] | implode)
      else
        .
      end
    )
  | join("")
  | gsub(" "; "")
;

if .property == "encode" then
  (.input.phrase | atbash_encode)
else
  (.input.phrase | atbash_decode)
end
