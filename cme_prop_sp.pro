pro cme_prop_sp,x_sol=x_sol,t_sol=t_sol,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,planets_str=planets_str,spacecraft_str=spacecraft_str,cme_val=cme_val
if ~keyword_set(t_sol) then t_sol = systim()
if ~keyword_set(cme_vel) then cme_vel=800 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
if (n_elements(x_sol) ne 2) then x_sol=[0,0]; lon-lat HGI
if (n_elements(dlong) eq 0) then dlong=45

cme_lon = long_hgihg(x_sol[0],/hg,date=t_sol) ;degrees

;===================================================================
;====================  Obtain properties of planets and spacecraft
ellip = planet_orbit(t_sol,3,planet=earth,all_planets=all_planets)
all_spacecraft  = spacecraft_path(t_sol,drange=300)

;===================================================================
;====================  Find if the planets are hit
cme_hit_object,all_planets,st_time=t_sol,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme_planets

;===================================================================
;====================  Find if the s/c are hit
if data_chk(all_spacecraft,/type) eq 8 then $
cme_hit_object,all_spacecraft,st_time=t_sol,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme_spacecraft


cme_val = (n_elements(cme_spacecraft) gt 0)?[cme_planets,cme_spacecraft]:cme_planets
planets_str = all_planets
spacecraft_str = all_spacecraft
;....
end
