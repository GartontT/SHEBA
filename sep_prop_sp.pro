pro sep_prop_sp,x0=x0,t0=t0,vel=vel,e_vel=e_vel,beta=beta,planets_str=planets_str,spacecraft_str=spacecraft_str
if ~keyword_set(t0) then t0 = systim()
if ~keyword_set(vel) then vel=400 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
if ~keyword_set(x0) then x0=[0]; lon-lat HG
if ~keyword_set(beta) then beta=0.9
beta=abs(beta) ;c times! relativistic particles

;; Make sure that the values are positive
vel=abs(vel)
e_vel = abs(e_vel)

;; --- Here it differs from the CME because the starting point is not
;;     changed to HGI.

;===================================================================
;====================  Find if the planets are hit
if data_chk(planets_str,/type) eq 8 then $
sep_hit_object,planets_str,st_time=t0,sep_lon=x0,sw_vel=vel,sw_e_vel=e_vel,beta=beta


;===================================================================
;====================  Find if the s/c are hit
if data_chk(spacecraft_str,/type) eq 8 then $
sep_hit_object,spacecraft_str,st_time=t0,sep_lon=x0,sw_vel=vel,sw_e_vel=e_vel,beta=beta

end
