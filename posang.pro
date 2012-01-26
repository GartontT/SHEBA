function posang,ang
  ang = ang mod 360
  posang = ang
  if ang lt 0 then posang=ang+360
return,posang
end
