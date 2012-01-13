pro sheba_back,$
   model=model,time_impact=time_impact,object=object,_extra=_extra,$;inputs
   time_sol=time_sol,solar_longitude=solar_longitude ;outputs

  if model eq 'cme' then prop_end_back,object=object,t0=time_impact,_extra=_extra

end
;...//////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\....
pro sheba_run,model=model,time_sol=time_sol,time_impact=time_impact,_extra=_extra
; to run CME model forward:
;sheba_run,model='cme',time_sol='2009/11/31T00:00:00',vel=1500,e_vel=100,width=20,x0=75,path_out='/tmp/sheba_test/cme01/'
; To run CME model backwars:
;sheba_run,model='cme',time_impact='2009/12/09T00:00:00',width=70,vel=2000,object='STEREOA',path_out='/tmp/sheba_test/cme01/'

  
; run backwards model to get time_sun for each model if time_impact is provided
if n_elements(time_impact) gt 0 then begin
   sheba_back,model=model,time_impact=time_impact,_extra=_extra

endif else begin

;All the models need the coordinates from the planets and spacecraft
;===================================================================
;====================  Obtain properties of planets and spacecraft
ellip = planet_orbit(time_sol,3,planet=earth,all_planets=all_planets);,model=model)
all_spacecraft  = spacecraft_path(time_sol,drange=300);,model=model)



if model eq 'cme' then prop_end,planets_str=all_planets,spacecraft_str=all_spacecraft,t0=time_sol,_extra=_extra

endelse


stop
end
