function pm180,angle
; Plus-Minus 180deg.
; converts an angle in a range [-180,180]
angle = posang(angle)

n_angle=(angle gt 180)?angle-360:angle

return,n_angle
end
