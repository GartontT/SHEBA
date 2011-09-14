pro cme_prop_v,planetn=planetn,x_sol=x_sol,t_sol=t_sol,t_planet=t_planet
if ~keyword_set(planetn) then planetn = 3
if ~keyword_set(t_sol) then t_sol = systim()
if ~keyword_set(t_planet) then t_planet = systim()
if anytim(t_planet) lt anytim(t_sol) then begin
   message,'impact time(t_planet) cannot be earlier than ejection time(t_sol)'
   goto,fin
endif
if ~keyword_set(x_sol) then x_sol=[0,0]; lon-lat HGI

cme_lon = long_hgihg(x_sol[0],/hg,date=t_sol) ;degrees
;===================================================================
;====================  Find where the CME intersect the planet orbit
ellip = planet_orbit(t_sol,planetn,planet=planet)
inter = intersect_ellipline(ellip,[tan(cme_lon * !DtoR),0],angle=cme_lon,/plot)
  ; and plot it
  plot,planet.orbit.orbit_x,planet.orbit.orbit_y,psym=4
  oplot,[0,inter[0]],[0,inter[1]]

;===================================================================
;=============== Calculate the time it takes to the CME to get there
cme_t = anytim(t_planet)-anytim(t_sol)
cme_vel = (sqrt(total(inter^2)) *  150e6) / cme_t   ; (radius[AU] * km/[AU] ) / s
print,'CME velocity: '+string(cme_vel)
  ; and plot it
  xyouts,0,0,t_sol
  xyouts,inter[0],inter[1],anytim(cme_t,/YOHKOH)

;===================================================================
;================ Calculate minimum dlong of cme for impact
cme_lon = (cme_lon lt 0)?360 + cme_lon:cme_lon

dlong = abs(planet.orbit.lon[10]-cme_lon) * 2
print,'CME minimum width: '+string(dlong)

if cme_lon-dlong/2 gt 180 then cme_lon = cme_lon-360.
planet_t1_lon = planet.orbit.lon[10]
if planet_t1_lon gt 180 then planet_t1_lon = planet_t1_lon-360.
if (planet_t1_lon le cme_lon+dlong/2) and (planet_t1_lon ge cme_lon-dlong/2) then print,'**** hit***' else print,'****miss****'
  ; and plot it
  recpol,inter[0],inter[1],rad,ang,/degrees
  polrec,rad,ang-dlong/2,xx,yy,/degrees
  oplot,[0,xx],[0,yy],linestyle=2
  polrec,rad,ang+dlong/2,xx,yy,/degrees
  oplot,[0,xx],[0,yy],linestyle=2

fin:
end
