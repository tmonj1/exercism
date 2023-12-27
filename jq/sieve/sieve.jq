def eratosthenes(n):
  if n >= last then
    .
  else (
    map(select((. <= n) or (. % n != 0)))
    | (if n == 2 then 3 else n + 2 end) as $next
    | eratosthenes($next)
    )
  end
;

def eratosthenes:
 [range(2; . + 1)] | eratosthenes(2)
;

.limit
| eratosthenes