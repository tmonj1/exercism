.phrase
| gsub("[- ]"; "") | ascii_downcase
| split("")        | sort            | join("")
| test("(.)\\1")   | not