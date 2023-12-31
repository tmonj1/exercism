{
  "AUG": "Methionine",
  "UUU": "Phenylalanine",
  "UUC": "Phenylalanine",
  "UUA": "Leucine",
  "UUG": "Leucine",
  "UCU": "Serine",
  "UCC": "Serine",
  "UCA": "Serine",
  "UCG": "Serine",	
  "UAU": "Tyrosine",
  "UAC": "Tyrosine",
  "UGU": "Cysteine",
  "UGC": "Cysteine",
  "UGG": "Tryptophan",
  "UAA": "STOP",
  "UAG": "STOP",
  "UGA": "STOP"
} as $codetable
| .strand
| [scan(".{1,3}"; "g")]
| [foreach .[] as $codon (
    0;
    ($codetable[$codon] // "ERROR") as $protein
    | if $protein == "STOP" and . != 2 then
      . = 1
    elif $protein == "ERROR" and . != 1 then
      ("Invalid codon" | halt_error)
    else
      .
    end;
    if . > 0 then
      empty
    else
      $codetable[$codon]
    end
  )]
