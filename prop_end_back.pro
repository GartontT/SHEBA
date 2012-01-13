pro prop_end_back,object=object,t0=t0,width=width,vel=vel,e_vel=e_vel,PATH_OUT=PATH_OUT
if ~keyword_set(object) then object='EARTH' else object=strupcase(object)
if ~keyword_set(t0) then t0 = anytim(systim(),/ccs) else t0=anytim(t0,/ccs)
if (n_elements(width) eq 0) then width=45 ; width in deg
if ~keyword_set(vel) then vel=800 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
if ~keyword_set(path_out) then path_out = '/tmp/'

planets    =  ['MERCURY','VENUS','EARTH','MARS','JUPITER',$
               'SATURN','URANUS','NEPTUNE','PLUTO']
spacecraft = ['Ulysses','StereoA','StereoB','Messenger',$
             'Voyager1','Voyager2','Galileo','Cassini',$
             'NewHorizons','Rosetta','Dawn']
planet_lab = where(object eq planets,nplanet)
spacecraft_lab = where(object eq strupcase(spacecraft),nspacecraft)

if nplanet ne 0 then $
   cme_prop_ps,planetn=planet_lab+1,t_planet=t0,cme_vel=vel,cme_lon=cme_lon,t_sun=t_sun
if nspacecraft ne 0 then $
   cme_prop_os,object=object,t_object=t0,cme_vel=vel,cme_lon=cme_lon,t_sun=t_sun

;if ILS fails then run the same query but using Earth
if n_elements(cme_lon) eq 0 then $
   prop_end_back,t0=t0,width=width,vel=vel,e_vel=e_vel,PATH_OUT=PATH_OUT $
else $
   sheba_run,model='cme',time_sol=t_sun,x0=cme_lon,width=width,vel=vel,e_vel=e_vel,PATH_OUT=PATH_OUT
end
