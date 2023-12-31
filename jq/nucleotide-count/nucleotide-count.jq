.strand
| if test("[^ACGT]") then
    "Invalid nucleotide in strand" | halt_error
  else
    .
  end
| split("")
| sort
| {
    A: ((rindex("A") // 0) - (index("A") // 1) + 1),
    C: ((rindex("C") // 0) - (index("C") // 1) + 1),
    G: ((rindex("G") // 0) - (index("G") // 1) + 1),
    T: ((rindex("T") // 0) - (index("T") // 1) + 1)
}


