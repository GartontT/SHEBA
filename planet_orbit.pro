function plot_orbit,planet,over=over,orbit=orbit,points=points,zero=zero,coord=coord,ninety=ninety,_extra=_extra

; check planet is a valid structure
if ~tag_exist(planet,'orbit_fit') then begin
   planet_input = planet
   ellip = planet_orbit(planet.pos_t0.date,planet.n,planet=planet)
endif
; check other variables

plot_command =(~keyword_set(over))?'plot,xrange=xrange,yrange=yrange':'oplot'

if keyword_set(orbit) then begin
;plot ellipse
   plot_ellips,planet.orbit_fit,over=over,_extra=_extra
   plot_command = 'oplot'
endif
if keyword_set(points) then begin
   xm=planet.orbit.orbit_x
   ym=planet.orbit.orbit_y
   a=execute(plot_command+',xm,ym,_extra=_extra')
   if keyword_set(coord) then for i=0,n_elements(xm)-1 do xyouts,xm[i]+0.01,ym[i]+0.01,planet.orbit.lon[i]
   plot_command = 'oplot'
endif
;


return,1
end

function planet_orbit,date,planet_n,planet=planet,all_planets=all_planets
;-
;  planet_orbit
;+

; Planet names
names=['Mercury','Venus','Earth','Mars','Jupiter','Saturn','Uranus','Neptune','Pluto']
; Number of days for each planet to complete an orbit
period=[0.2408,0.6152,1.0,1.8809,11.862,29.458,84.01,164.79,248.54]; * 365.25

n_steps = 21


; Define structure to save orbit parameters
orbit_steps = {date:strarr(n_steps),radio:fltarr(n_steps),lon:fltarr(n_steps),lat:fltarr(n_steps),orbit_x:fltarr(n_steps), orbit_y:fltarr(n_steps)}

jd_struct = anytim2jd(date)
jd_date = jd_struct.int + jd_struct.frac

year = (strsplit(anytim(date,/ecs),'/',/extract))[0]
long_asc_node = 74+(22.+((year-1900)*.84))/60.
inputs = {st_time:'', st_long:0., st_long_hci:0.,width:0., cme_vel:0., cme_vel_e: 0.}
minmaxt = {t_min:'', t_max:''}

; calculate each parameter for each planet
; TODO: Check if this loop can be avoided using #...  
;       the question is how to fill in the variables?
for i=0,8 do begin
   jd_dates = ((findgen(n_steps)-fix(n_steps/2))* period[i] * 365.25 / n_steps ) + jd_date

   ; calculate positions for all dates
   helio, jd_dates, i+1, hel_rad, hel_lon, hel_lat
   polrec,hel_rad,hel_lon - long_asc_node,dx,dy,/degrees

   ; fill in orbit structure
   orbit_steps.date = anytim(jd2ecs(jd_dates),/CCSDS)
   orbit_steps.radio = hel_rad
   orbit_steps.lon = hel_lon -long_asc_node
   orbit_steps.lat = hel_lat
   orbit_steps.orbit_x = dx
   orbit_steps.orbit_y = dy

   start_pos = {date:   orbit_steps.date[n_steps/2],   radio:orbit_steps.radio[n_steps/2], $
                lon:    orbit_steps.lon[n_steps/2],    lat:  orbit_steps.lat[n_steps/2], $
                orbit_x:orbit_steps.orbit_x[n_steps/2],orbit_y:orbit_steps.orbit_y[n_steps/2]}
   ; fit orbit to ellipse
   param = mpfitellipse(orbit_steps.orbit_x, orbit_steps.orbit_y,/tilt,/quiet)
   ; create structure with values for each planet
   planet={name:names[i],n:i+1,pos_t0:start_pos, $      ;Name,Number,St_position
           orbit_steps:orbit_steps,orbit_fit:param, $   ;Orbit points, ellip fit
           HitOrMiss:0b,pos_thit:start_pos,$            ;Hit or Not!, Pos at t_hit
           input:inputs,minmaxt:minmaxt}               ;Input values, MinMax hit times
   
   ; save all planets in a single structure
   all_planets=(i eq 0)?planet:[all_planets,planet]
endfor

planet = all_planets[planet_n-1]
return,all_planets[planet_n-1].orbit_fit

end


