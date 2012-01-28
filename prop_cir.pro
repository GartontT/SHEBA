pro prop_cir,planets_str=planets_str, spacecraft_str=spacecraft_str,t0=t0,x0=x0,vel=vel,e_vel=e_vel,PATH_OUT=PATH_OUT
if ~keyword_set(path_out) then path_out='/tmp/cir_'+string(strcompress(t0,/remove_all))
if ~keyword_set(t0) then t0 = anytim(systim(),/ccs) else t0=anytim(t0,/ccs)
if ~keyword_set(x0) then x0=[0]; lon-lat HG
if ~keyword_set(vel) then vel=400 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s

;===================================================================
;====================  Obtain properties of planets and spacecraft if they are not input.
if data_chk(planets_str,/type) ne 8 then ellip = planet_orbit(t0,3,planet=earth,all_planets=planets_str)
if data_chk(spacecraft_str,/type) ne 8 then spacecraft_str  = spacecraft_path(t0,drange=15)

cir_prop_sp,x0=x0,t0=t0,vel=vel,e_vel=e_vel,planets_str=planets_str,spacecraft_str=spacecraft_str

ploting_prop,planets_str,spacecraft_str,path_out,/plot_cir,model='cir'

writing_prop_out,planets_str,spacecraft_str,path_out,model='cir'

end
