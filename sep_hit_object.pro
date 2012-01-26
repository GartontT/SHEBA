pro sep_hit_object,objects,st_time=st_time,sep_lon=sep_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel,beta=beta

  for i=0,n_elements(objects)-1 do begin

;;===================== a planet ==================
     if tag_exist(objects[i],'orbit_fit') then begin
        planet_i = objects[i]
        sep_planet_hit,planet_i,st_time=st_time,sep_lon=sep_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel
        objects[i] = planet_i
        
;;===================== a s/c =====================
     endif else begin
        sc_i = objects[i]
        sep_spacecraft_hit,sc_i,st_time=st_time,sep_lon=sep_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel
        objects[i] = sc_i
        
     endelse

;;===================== calculate impact time  =================
     objects[i].input.beta = beta
     if objects[i].HitOrMiss then begin
        rot_sun = 14.4
        theta_sp = findgen(2*objects[i].pos_thit.spiral_angle)/2.
        spiral = -(objects[i].pos_thit.sw_vel_au/rot_sun) * theta_sp
        objects[i].pos_thit.spiral_dist = arcdist(spiral,theta_sp) ; distance in AU
        objects[i].pos_thit.delta_time = objects[i].pos_thit.spiral_dist * 500. / objects[i].input.beta  ; (1 AU = 150e6 km)/(c = 3e5 km/s) = 500 s.
        objects[i].pos_thit.date = anytim(anytim(objects[i].input.st_time)+objects[i].pos_thit.delta_time,/CCSDS)
;TODO: The objects should be updated to new positions. Voyager2 is 1.5
;months far.
     endif
  endfor
;....
end
