function plot_orbit,planet,over=over,orbit=orbit,points=points,zero=zero,coord=coord,ninety=ninety,_extra=_extra

; check planet is a valid structure
; check other variables

plot_command =(~keyword_set(over))?'plot,xrange=xrange,yrange=yrange':'oplot'

if keyword_set(orbit) then begin
;plot ellipse
   plot_ellips,planet.param,over=over,_extra=_extra
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

function planet_orbit,date,planet_n,planet=planet


; Number of days for each planet to complete an orbit
period=[0.2408,0.6152,1.0,1.8809,11.862,29.458,84.01,164.79,248.54]; * 365.25

n_steps = 21

step_size = period[planet_n-1]*365.25 / n_steps

jd_struct = anytim2jd(date)
jd_date = jd_struct.int + jd_struct.frac

year = (strsplit(anytim(date,/ecs),'/',/extract))[0]
long_asc_node = 74+(22.+((year-1900)*.84))/60.

;start position
helio, jd_date, planet_n, hel_rad, hel_lon, hel_lat
polrec,hel_rad,hel_lon - long_asc_node,dx,dy,/degrees
start = {date:jd2ecs(jd_date),$
         radio:hel_rad,$
         lon:hel_lon - long_asc_node,$
         lat:hel_lat,$
         orbit_x: dx,$
         orbit_y: dy}

;rest of the orbit
jd = jd_date - (fix(n_steps/2)*step_size)

values = fltarr(n_steps)
planet_steps = {date:strarr(n_steps),radio:values,lon:values,lat:values,orbit_x: values, orbit_y: values}


for i=0,n_steps-1 do begin
   helio, jd, planet_n, hel_rad, hel_lon, hel_lat
   planet_steps.radio[i]=hel_rad
   planet_steps.lon[i]=hel_lon - long_asc_node
   planet_steps.lat[i]=hel_lat
   planet_steps.date[i] = jd2ecs(jd)
   polrec,hel_rad,hel_lon - long_asc_node,dx,dy,/degrees
   planet_steps.orbit_x[i] = dx
   planet_steps.orbit_y[i] = dy
   ;increment the date for then next loop
   jd = jd + step_size
endfor

;Get parameter values fitting steps to an ellipsis
 param = mpfitellipse(planet_steps.orbit_x, planet_steps.orbit_y,/tilt,/quiet)

planet={n:planet_n,start:start,orbit:planet_steps,param:param}
return,param
end
