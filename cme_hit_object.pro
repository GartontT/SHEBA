pro cme_hit_object,objects,st_time=st_time,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme_val

  for i=0,n_elements(objects)-1 do begin

;;===================== a planet ==================
     if tag_exist(objects[i],'orbit_fit') then begin
         planet_i = objects[i]
        planet_hit,planet_i,st_time=st_time,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme
        objects[i] = planet_i
        cme_val = (n_elements(cme_val) eq 0)?cme:[cme_val,cme]

;;===================== a s/c =====================
     endif else begin
        sc_i = objects[i]
        spacecraft_hit,sc_i,st_time=st_time,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme
        objects[i] = sc_i
        cme_val = (n_elements(cme_val) eq 0)?cme:[cme_val,cme]

     endelse

  endfor
;....
end
