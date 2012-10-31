;==================================================================
;Copyright 2011, 2012  David Pérez-Suárez (TCD-HELIO)
;===================GNU license====================================
;This file is part of SHEBA.
;
;    SHEBA is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    SHEBA is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with SHEBA.  If not, see <http://www.gnu.org/licenses/>.
;==================================================================
function sheba_header,model=model
str =  ''

  if model eq 'cme' then $
     str = "time_start,long_hg,long_hci,long_width,v,v_err,target_obj,r_hci,HitOrMiss,ETA,ETA_min,ETA_max,Dt,Dt_min,Dt_max"
  if model eq 'sep' then $
     str = "time_start,long_hg,long_hci,v,v_err,beta,target_obj,r_hci,HitOrMiss,v_estimated,ETA,Dt"
  if model eq 'cir' then $
     str = "time_start,long_hg,long_hci,v,v_err,target_obj,r_hci,HitOrMiss,ETA,ETA_min,ETA_max,Dt,Dt_min,Dt_max"

return,str
end

function sheba_input_str,object,model=model
str = ''
 
 if model eq 'cme' then $
    str = object[0].input.st_time + ',' + $
          string(object[0].input.st_long,format='(F6.2)') +',' + $
          string(object[0].input.st_long_hci,format='(F6.2)') +',' + $
          string(object[0].input.width,format='(F6.2)') +','+ $
          string(object[0].input.cme_vel,format='(F7.2)') +','+$
          string(object[0].input.cme_vel_e,format='(F7.2)')
 if model eq 'sep' then $
    str = object[0].input.st_time + ',' + $
          string(object[0].input.st_long,format='(F6.2)') +',' + $
          string(object[0].input.st_long_hci,format='(F6.2)') +',' + $
          string(object[0].input.sw_vel,format='(F7.2)') +','+$
          string(object[0].input.sw_vel_e,format='(F7.2)') +','+$
          string(object[0].input.beta,format='(F4.2)')
 if model eq 'cir' then $
    str = object[0].input.st_time + ',' + $
          string(object[0].input.st_long,format='(F6.2)') +',' + $
          string(object[0].input.st_long_hci,format='(F6.2)') +',' + $
          string(object[0].input.sw_vel,format='(F7.2)') +','+$
          string(object[0].input.sw_vel_e,format='(F7.2)')
return,str
end

function sheba_output_str,object,model=model
str = ''
;======================== SEP values ============================================
swvel=((object.HitOrMiss eq 0))?'':string(object.pos_thit.sw_vel,format='(F7.2)')
dt =  ((object.HitOrMiss eq 0))?'':string(object.pos_thit.delta_time,format='(F12.2)')

;======================== CME values ============================================
t1_out = (object.hitormiss eq 0)?'':object.pos_thit.date
t1_out_min = (t1_out eq '')?'':object.minmaxt.t_min
t1_out_max = (t1_out eq '')?'':object.minmaxt.t_max
dt1_out = (t1_out eq '')?'':string((anytim(object.pos_thit.date) - anytim(object.pos_t0.date))/(3600.*24.),format='(F7.2)')
dt1_out_min = (t1_out eq '')?'':string((anytim(object.minmaxt.t_min) - anytim(object.pos_t0.date))/(3600.*24.),format='(F7.2)')
dt1_out_max = (t1_out eq '')?'':string((anytim(object.minmaxt.t_max) - anytim(object.pos_t0.date))/(3600.*24.),format='(F7.2)')
 
 if (model eq 'cme') or (model eq 'cir') then $
     str = strupcase(object.name) + ',' + $ ; Object
           string(object.pos_t0.radio,format='(F7.3)') +',' +  $ ; distance
           string(object.HitOrMiss,format='(I1)') +',' +  $     ; HitOrMiss
           t1_out +',' + $                                      ; time to reach earth
           t1_out_min +',' + $                                  ; min time
           t1_out_max   +',' + $                                ; max time
           dt1_out +',' + $                                     ; days to reach earth
           dt1_out_min +',' + $                                 ; min number of days
           dt1_out_max                                          ; max number of days

   
 if model eq 'sep' then $
    str = strupcase(object.name) + ',' + $ ; Object
          string(object.pos_t0.radio,format='(F7.3)') +',' +  $ ; distance
          string(object.HitOrMiss,format='(I1)') +',' +  $      ; HitOrMiss
          swvel+',' + $                                         ; velocity stimated
          t1_out+','+$                                           ; time of arrival
          dt                                                    ; dt in seconds.

return,str
end

pro writing_tables,planets_str,spacecraft_str,path_out=path_out,votable=votable,model=model

file_out = path_out+model+'_pm'
openw,lun,file_out+'.csv',/get_lun
printf,lun,sheba_header(model=model)

start_str = sheba_input_str(planets_str,model=model)

object_struct = (data_chk(spacecraft_str,/type) eq 8 )?['planets_str','spacecraft_str']:'planets_str'

 for j=0,n_elements(object_struct)-1 do begin
    a = execute('objects = '+object_struct[j])
    for i = 0,n_elements(objects)-1 do begin
       rest_str = sheba_output_str(objects[i],model=model)
       printf,lun,start_str+','+rest_str
    endfor
 endfor
close,/all

;  votable optative (stilts)
stilts_command = './stilts tcopy '+file_out+'.csv ifmt=csv '+file_out+'00.votable ofmt=votable'
stilts_change  = './stilts tpipe cmd=@'+model+'_stilts_script '+file_out+'00.votable ofmt=votable out='+file_out+'.votable'
if keyword_set(votable) then begin
   spawn,stilts_command
   spawn,stilts_change
   delete_midfiles = 'rm '+file_out+'00.votable'
   spawn,delete_midfiles
endif

end

pro writing_web_input,object,file=file,model=model

openw,lun,file,/get_lun
  printf,lun,"<li> Start Time <div class='input'>"+object.input.st_time+"</div></li>"
  printf,lun,"<li> Longitude <div class='input'>"+string(object.input.st_long,format='(F6.2)')+"</div></li>"

if model eq 'cme' then begin
   printf,lun,"<li> Width <div class='input'>"+string(object.input.width,format='(F6.2)')+"</div></li>"
   printf,lun,"<li> CME speed <div class='input'>"+string(object.input.cme_vel,format='(F7.2)') + $
          " &plusmn; "+string(object.input.cme_vel_e,format='(F7.2)')+"</div></li>"
endif

if (model eq 'sep') or (model eq 'cir') then begin
   printf,lun,"<li> SolarWind speed <div class='input'>"+string(object.input.sw_vel,format='(F7.2)') + $
          " &plusmn; "+string(object.input.sw_vel_e,format='(F7.2)')+"</div></li>"
   if (model eq 'sep') then printf,lun,"<li> Beta <div class='input'>"+string(object.input.beta,format='(F4.2)')+"</div></li>"
endif

  printf,lun,"<li> <a href='http://cagnode58.cs.tcd.ie:8080/PropagationModelGUI/'><button type='button'>Reset</button></a></div></li>"
  printf,lun,"</ul> </div>  <!-- input values -->"
close,/all

end

pro writing_web_output,planets_str,spacecraft_str,file=file,model=model

openw,lun,file,/get_lun
  printf,lun,"	<div class='Result'> <!-- result box -->"
  phits = where(planets_str.hitormiss,nphits)
  if data_chk(spacecraft_str,/type) eq 8 then  $
     schits = where(spacecraft_str.hitormiss eq 1,nschits) $
  else nschits = 0

  objects_str = (data_chk(spacecraft_str,/type) ne 8 )?'planets_str':['planets_str','spacecraft_str']
  nhits_str = ['nphits','nschits']
  hits_str = ['phits','schits']

  if nphits+nschits eq 0 then begin
     printf,lun," <ul> <li> No Object is hit </li></ul>"
  endif else begin
     printf,lun," <ul> <li> Output </li></ul>" 
     printf,lun,"    <table>" 

     if (model eq 'cme') or (model eq 'cir') then begin
        printf,lun,"     <tr> <th> Object </th> <th> ETA min</th> <th> ETA max </th> <th> Dt min(days) </th><th> Dt max(days) </th></tr>"        
        for j=0,n_elements(objects_str)-1 do begin
           a = execute('objects = '+objects_str[j])
           a = execute('nhits = '+ nhits_str[j])
           if nhits ne 0 then begin
           a = execute('hits = '+ hits_str[j])
              for i=0,nhits-1 do begin
                 t_min = strsplit(objects[hits[i]].minmaxt.t_min,"T",/extract)
                 t_max = strsplit(objects[hits[i]].minmaxt.t_max,"T",/extract)
                 printf,lun,"     <tr> <td>"+strupcase(objects[hits[i]].name)+"</td><td>"+$
                        t_min[0]+"<br>"+t_min[1]+"</td><td>"+$
                        t_max[0]+"<br>"+t_max[1]+"</td><td align='center'>"+$
                        string((anytim(objects[hits[i]].minmaxt.t_min) - anytim(objects[hits[i]].pos_t0.date))/(3600.*24.),format='(F6.2)')+"</td><td>"+$
                        string((anytim(objects[hits[i]].minmaxt.t_max) - anytim(objects[hits[i]].pos_t0.date))/(3600.*24.),format='(F6.2)')+"</td><td>"+$
                        "</td></tr>"
              endfor
           endif
        endfor
     endif
     
     if model eq 'sep' then begin
        printf,lun,"     <tr> <th> Object </th> <th> Speed</th> <th> ETA </th> <th> Dt(seconds) </th></tr>"      
        for j=0,n_elements(objects_str)-1 do begin
           a = execute('objects = '+objects_str[j])
           a = execute('nhits = '+ nhits_str[j])
           if nhits ne 0 then begin
           a = execute('hits = '+ hits_str[j])
              for i=0,nhits-1 do begin
                 t_min = strsplit(objects[hits[i]].pos_thit.date,"T",/extract)
                 printf,lun,"     <tr> <td>"+strupcase(objects[hits[i]].name)+"</td><td>"+$
                                   string(objects[hits[i]].pos_thit.sw_vel,format='(F7.2)')+"</td><td>"+$
                                   t_min[0]+"<br>"+t_min[1]+"</td><td align='center'>"+$
                                   string(objects[hits[i]].pos_thit.delta_time,format='(I7)')+$
                   "</td></tr>"
              endfor
           endif
        endfor
     endif

     printf,lun,"    </table>" 
     printf,lun,"<div class='download'><a href='./"+model+"_pm.votable'><button type='button'>Download VOTable</button></a></div>"
  endelse
  printf,lun,"   </div> <!-- result box -->"
close,/all

end

pro writing_web_cxs,stdate,file=file


openw,lun,file ,/get_lun
  printf,lun,"		<div class='links'> <!-- links box -->"
  printf,lun,"	  <ul>"
  date=strsplit(anytim(stdate,/ecs,/date),'/',/extract)
  date0=strsplit(anytim(anytim(stdate)-(24*3600.),/ecs,/date),'/',/extract)
  date1=strsplit(anytim(anytim(stdate)+(24*3600.),/ecs,/date),'/',/extract)
  link_goes = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=00&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=goesplotter&format=html"
  printf,lun,"      <li> <a href='"+link_goes+"'> GOES plotter</a></li>"
  link_flares = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=20&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=flareplotter&format=html"
  printf,lun,"      <li> <a href='"+link_flares+"'> Flare plotter</a></li>"
  
  sm_link = "http://solarmonitor.org/index.php?date="+date[0]+date[1]+date[2]
  printf,lun,"      <li> <a href='"+sm_link+"'> Solar Monitor for "+anytim(stdate,/vms,/date)+"</a></li>"

  sw_link = "http://spaceweather.com/archive.php?view=1&day="+date[2]+"&month="+date[1]+"&year="+date[0]
  printf,lun,"      <li> <a href='"+sw_link+"'> Space Weather for "+anytim(stdate,/vms,/date)+"</a></li>"

  printf,lun," </ul>"
close,/all


end

pro writing_web,planets_str,spacecraft_str,file_out=file_out,model=model
  file_input = file_out+'_input_'
  file_output = file_out+'_output_'
  file_cxs = file_out+'_cxs_'

  writing_web_input,planets_str[0],file=file_input, model=model
  writing_web_output,planets_str,spacecraft_str,file=file_output, model=model
  writing_web_cxs,planets_str[0].input.st_time,file=file_cxs

;spawn cat header .... footer > file_out
join_all = 'cat '+model+'_index_header.html '+file_input+' '+file_output+' '+file_cxs +' '+model+'_index_footer.html > '+ file_out
spawn,join_all

;spawn delete midfiles
delete_midfiles = 'rm '+file_input+' '+file_output+' '+file_cxs 
spawn,delete_midfiles

end

pro writing_prop_out,planets_str,spacecraft_str,path_out,model=model

  writing_tables,planets_str,spacecraft_str,path_out=path_out,/votable,model=model
  writing_web,planets_str,spacecraft_str,file_out=path_out+'index.html',model=model


end
