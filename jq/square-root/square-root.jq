# mysqrt/2
def mysqrt(min;max):
  if min >= max then
    min
  else
    mysqrt(min + 1; (. / (min + 1) | floor))
  end
;

# mysqrt/0
def mysqrt:
  mysqrt(1; .)
;

# main
.radicand | mysqrt
