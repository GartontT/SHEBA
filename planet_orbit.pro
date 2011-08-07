function planet_orbit,date,planet_n,planet=planet


; Number of days for each planet to complete an orbit
period=[0.2408,0.6152,1.0,1.8809,11.862,29.458,84.01,164.79,248.54]; * 365.25

n_steps = 21

step_size = period[planet_n-1]*365.25 / n_steps

jd_struct = anytim2jd(date)
jd_date = jd_struct.int + jd_struct.frac

jd = jd_date - (fix(n_steps/2)*step_size)

values = fltarr(n_steps)
planet_steps = {date:strarr(n_steps),radio:values,lon:values,lat:values,orbit_x: values, orbit_y: values}

for i=0,n_steps-1 do begin
   helio, jd, planet_n, hel_rad, hel_lon, hel_lat
   planet_steps.radio[i]=hel_rad
   planet_steps.lon[i]=hel_lon
   planet_steps.lat[i]=hel_lat
   planet_steps.date[i] = jd2ecs(jd)
   polrec,hel_rad,hel_lon,dx,dy,/degrees
   planet_steps.orbit_x[i] = dx
   planet_steps.orbit_y[i] = dy

   jd = jd + step_size
endfor

;Get parameter values fitting steps to an ellipsis
 param = mpfitellipse(planet_steps.orbit_x, planet_steps.orbit_y,/tilt,/quiet)

planet={n:planet_n,orbit:planet_steps,param:param}
return,param
end
