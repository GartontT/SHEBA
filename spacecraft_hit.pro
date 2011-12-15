pro spacecraft_hit,spacecraft_str,st_time=st_time,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme_val

time_diff = (anytim(spacecraft_str.orbit_steps.date)-anytim(st_time))
spacecraft_exist = (min(time_diff) lt 2*3600*24.)?1b:0b

if spacecraft_exist then begin
;===================================================================
;=========  Calculate the rad of CME at the times for s/c
   cme_r = ((time_diff)#$
            (cme_vel + [-1,0,1]*e_vel))/150e6 ; [cme_r in AU]

   hit_label = fltarr(3)
   for i = 0,2 do begin
      closest = min(abs(spacecraft_str.orbit_steps.radio-cme_r[*,i]),closest_label)
      hit_label[i]=closest_label
   endfor

   cme_t = spacecraft_str.orbit_steps.date[hit_label]

;===================================================================
;================ Fill in values for the time where it should hit
   spacecraft_str.HitOrMiss = 1b ;as a label to check later on.
   spacecraft_str.pos_thit.date    = spacecraft_str.orbit_steps.date[hit_label[1]]
   spacecraft_str.pos_thit.radio   = spacecraft_str.orbit_steps.radio[hit_label[1]]
   spacecraft_str.pos_thit.lon     = spacecraft_str.orbit_steps.lon[hit_label[1]]
   spacecraft_str.pos_thit.lat     = spacecraft_str.orbit_steps.lat[hit_label[1]]
   spacecraft_str.pos_thit.orbit_x = spacecraft_str.orbit_steps.orbit_x[hit_label[1]]
   spacecraft_str.pos_thit.orbit_y = spacecraft_str.orbit_steps.orbit_y[hit_label[1]]

;===================================================================
;================ Fill in input parameters
   spacecraft_str.input.st_time     = anytim(st_time,/CCSDS)
   spacecraft_str.input.st_long     = long_hgihg(cme_lon,/ihg,date=st_time)
   spacecraft_str.input.st_long_hci = cme_lon
   spacecraft_str.input.width       = dlong
   spacecraft_str.input.cme_vel     = cme_vel
   spacecraft_str.input.cme_vel_e   = e_vel

;===================================================================
;================ Fill in min and max expected times
   spacecraft_str.minmaxt.t_min     = cme_t[2]
   spacecraft_str.minmaxt.t_max     = cme_t[0]

;===================================================================
;====================== Calculate whether it hits or miss the planet
   if spacecraft_str.HitOrMiss eq 1b then $
      spacecraft_str.HitOrMiss = angleinrange(cme_lon,dlong,spacecraft_str.pos_thit.lon)

;===================================================================
;================  Output cme_val variable array
   cme_val = [(anytim(cme_t[1])-anytim(st_time))/(3600.*24.),spacecraft_str.pos_thit.radio] ; [days,au]
endif

end
