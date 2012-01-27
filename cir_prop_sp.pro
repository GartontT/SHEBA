pro cir_prop_sp,x0=x0,t0=t0,vel=vel,e_vel=e_vel,planets_str=planets_str,spacecraft_str=spacecraft_str
if ~keyword_set(x0) then x0=[0]; lon-lat HG
if ~keyword_set(t0) then t0 = systim()
if ~keyword_set(vel) then vel=600 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s

;===================================================================
;====================  Find if the planets are hit
if data_chk(planets_str,/type) eq 8 then $
cir_hit_object,planets_str,st_time=t0,cir_lon=x0,sw_vel=vel,sw_e_vel=e_vel

;===================================================================
;====================  Find if the s/c are hit
;if data_chk(spacecraft_str,/type) eq 8 then $
;cir_hit_object,spacecraft_str,st_time=t0,cir_lon=x0,sw_vel=vel,sw_e_vel=e_vel


end
