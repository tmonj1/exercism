(.subject | ascii_downcase) as $sub 
| (.subject | ascii_downcase |. / "" |  sort | join("")) as $sorted_sub
| .candidates
| map(
    if (ascii_downcase) != $sub and 
       (ascii_downcase | . / "" | sort | join("")) == $sorted_sub then
      .
    else
      empty
    end
  )