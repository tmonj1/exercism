.moment
| if ((split("T") | length) == 1) then
    (. + "T00:00:00Z")
  else
    (. + "Z")
  end
| (fromdate + 1000000000)
| strftime("%Y-%m-%dT%H:%M:%S")