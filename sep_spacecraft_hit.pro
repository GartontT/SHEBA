pro sep_spacecraft_hit,spacecraft_str,st_time=st_time,sep_lon=sep_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel

time_diff = (anytim(spacecraft_str.orbit_steps.date)-anytim(st_time))
spacecraft_exist = (min(time_diff) lt 2*3600*24.)?1b:0b

if spacecraft_exist then begin

;===================================================================
;================ Fill in input parameters
   spacecraft_str.input.st_time     = anytim(st_time,/CCSDS)
   spacecraft_str.input.st_long     = sep_lon
   spacecraft_str.input.st_long_hci = long_hgihg(sep_lon,/hg,date=st_time)
   spacecraft_str.input.width       = 0
   spacecraft_str.input.cme_vel     = 0
   spacecraft_str.input.cme_vel_e   = 0
   spacecraft_str.input.sw_vel      = sw_vel
   spacecraft_str.input.sw_vel_e    = sw_e_vel


;===================================================================
;================ Fill in values for the time where it should hit
   exist_values = where(finite(spacecraft_str[0].orbit_steps.lon),count)
   if count eq 0 then goto,out
   closest = min(abs(anytim(spacecraft_str.orbit_steps.date[exist_values])-anytim(st_time)),closest_label)
   spacecraft_str.HitOrMiss        = 1b ;as a label to check later on.
   spacecraft_str.pos_thit.date    = spacecraft_str.orbit_steps.date[exist_values[closest_label]]
   spacecraft_str.pos_thit.radio   = spacecraft_str.orbit_steps.radio[exist_values[closest_label]]
   spacecraft_str.pos_thit.lon     = spacecraft_str.orbit_steps.lon[exist_values[closest_label]]
   spacecraft_str.pos_thit.lat     = spacecraft_str.orbit_steps.lat[exist_values[closest_label]]
   spacecraft_str.pos_thit.orbit_x = spacecraft_str.orbit_steps.orbit_x[exist_values[closest_label]]
   spacecraft_str.pos_thit.orbit_y = spacecraft_str.orbit_steps.orbit_y[exist_values[closest_label]]


;===================================================================
;=========  Calculate the velocity needed for hitting

rot_sun = 14.4
vel_wind = sw_vel+[-1,1]*sw_e_vel
vel_wind_au = ( vel_wind / 150e6 ) * 24. * 60. * 60.

diff_angle = posang(spacecraft_str.input.st_long_hci - spacecraft_str.pos_thit.lon)
vel_2hitSC = (spacecraft_str.pos_thit.radio) * rot_sun / diff_angle

while vel_2hitSC gt max(vel_wind_au) do begin
   print,'t '+string(vel_2hitSC)
   diff_angle = diff_angle + 360
   vel_2hitSC = (spacecraft_str.pos_thit.radio) * rot_sun / diff_angle

endwhile

print, diff_angle, vel_2hitSC,vel_wind_au;, vel_2hitPlanet*150e6/24./60./60.,vel_wind_au*150e6/24./60./60.
spacecraft_str.sw_thit = vel_2hitSC

;===================================================================
;====================== Calculate whether it hits or miss the planet
spacecraft_str.HitOrMiss = numinrange(vel_2hitSC,vel_wind_au)

endif
out:
end
