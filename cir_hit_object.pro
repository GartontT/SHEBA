pro cir_hit_object,objects,st_time=st_time,cir_lon=cir_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel

  for i=0,n_elements(objects)-1 do begin

;;===================== a planet ==================
     if tag_exist(objects[i],'orbit_fit') then begin
        planet_i = objects[i]
        cir_planet_hit,planet_i,st_time=st_time,cir_lon=cir_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel
        objects[i] = planet_i
        
;;===================== a s/c =====================
     endif else begin
        sc_i = objects[i]
        cir_spacecraft_hit,sc_i,st_time=st_time,cir_lon=cir_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel
        objects[i] = sc_i
      endelse

  endfor

end
