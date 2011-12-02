function angleinrange2,ang,range,radians=radians
  if n_elements(ang) ne 1 then begin
     print,'*** angleinrange2 can just check one angle at the moment'
     return,-1
  endif
  if n_elements(range) ne 2 then begin
     print,'*** angleinrange2 needs a range of two angles'
     return,-1
  endif
  if range[0] eq range[1] then begin
     print,'*** range input is 0!'
     return,-1
  endif
  if keyword_set(radians) then begin
     ;converting values to degrees
     ang = ang/!DTOR
     range = range/!DTOR
  endif
  ang = ang mod 360.
  range = range mod 360.

  test = [0,0]
  while total(test) ne 2 do begin
     if range[0] lt range[1] then test[0] = 1 else range[0]-= 360
     if not ((range[0] lt 0) and (range[1] lt 0)) then test[1] = 1 else range += 360
  endwhile

  if ((range[1] ge ang) and (range[0] le ang)) then return,1 else return,0

end
