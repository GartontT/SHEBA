function intersect_ellipline,ellip,line,angle=angle,plot=plot,_extra=_extra
; ellip: array with the ellip parameters as from fitting ellipse
; line: array with the line parameters: y = line[0]x + line[1] (mx+b)
; angle: line[0] angle with the x axis

angle = (~keyword_set(angle))?atan(line[0]):angle
angle = (angle ge 180)?angle-360:angle
;ploting
if keyword_set(plot) then begin
   plot_line,line,_extra=_extra
   plot_ellips,ellip,/over,/zero
;   pause
endif

;1st transformation: set the ellipse in a new system: (0,0)
; then the line needs to be translated
newb = (line[0]*ellip[2] + line[1]) - ellip[3]
trans_line = [line[0],newb]

if keyword_set(plot) then begin
   plot_line,trans_line,_extra=_extra
   plot_ellips,[ellip[0:1],0,0,ellip[4]],/over,/zero
;   pause
endif


;2nd transformation: rotation of tilt
;new tilt of line, if ellip[4] ne 0
newm = tan(atan(trans_line[0])+ellip[4])
;new intersection point, ie, rotation that angle
b_y=trans_line[1]*cos(ellip[4])
b_x=-trans_line[1]*sin(ellip[4])
rot_line = [newm,b_y-newm*b_x]

if keyword_set(plot) then begin
   plot_line,rot_line,_extra=_extra
   plot_ellips,[ellip[0:1],0,0,0],/over,/zero
;   pause
endif

;Solve the system where ellipse and line cuts
; ellipse: x^2/a^2 + y^2/b^2 = 1  => a = ellip[0]   ; b = ellip[1]
; line:    y = mx + c             => m = rot_line[0]; c = rot_line[1]
; [1/a^2 + (m/b)^2]x^2 + [2mc/b^2]x +[(c/b)^2-1] = 0
; x = -b/2a +/- sqrt(b^2 - 4ac)/2a
a = (1/ellip[0]^2 + (rot_line[0]/ellip[1])^2)
b = 2*rot_line[0]*rot_line[1]/ellip[1]^2
c = (rot_line[1]/ellip[1])^2 -1 

root = (b^2 - 4*a*c)
if root ge 0 then begin
   x1 = (-b + sqrt(root))/(2*a)
   x2 = (-b - sqrt(root))/(2*a)
   x = [x1,x2]
   y = rot_line[0]*x + rot_line[1]
endif 
if root lt 0 then begin
   message,'There is not intersection'
   return,-1
endif

if keyword_set(plot) then begin
   plot_line,rot_line,_extra=_extra
   plot_ellips,[ellip[0:1],0,0,0],/over,/zero
   plots,x,y,psym=4
;   pause
endif


;convert point to the original reference system
; Rotate back 
xx = x*cos(-ellip[4]) - y*sin(-ellip[4])
yy = x*sin(-ellip[4]) + y*cos(-ellip[4])

if keyword_set(plot) then begin
   plot_line,trans_line,_extra=_extra
   plot_ellips,[ellip[0:1],0,0,ellip[4]],/over,/zero
   plots,xx,yy,psym=4
;   pause
endif


; Translate back
xx_t = xx + ellip[2]
yy_t = yy + ellip[3]

if keyword_set(plot) then begin
   plot_line,line,_extra=_extra
   plot_ellips,ellip,/over,/zero
   plots,xx_t,yy_t,psym=4
;   pause
endif

; find which of the two solutions is the one
; in the direction of the line
angle_int = atan(yy_t,xx_t)
amb = min(abs(angle_int - angle),pos)
return,[xx_t[pos],yy_t[pos]]

end
