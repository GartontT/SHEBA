@./planet_orbit.pro
@./cme_prop_sp.pro
pro ploting_prop,planets,cme,cme_s,file_out

lon_0 = cme_s[0]
width = cme_s[1]
;print,'lon_0 = '+string(lon_0)
inner_r = [-2.5,2.5]
outer_r = [-46.5,46.5]

cme_t = 0
cme_r = 0

planets_colors=[9,7,5,3,6,2,4,10,9]

for i =0,8 do begin
   cme_t =[cme_t,cme[(i*2)]]
   cme_r =[cme_r,cme[(i*2)+1]]
endfor


set_plot,'z'
loadct,0,/silent
COMBINE_COLORS,/LOWER	
loadct,5,/silent
COMBINE_COLORS
set_line_color
Device, Set_Resolution=[2400, 2400]
;window,15,xsize=600, ysize=600
!p.background = 255
position=[0.1,0.1,0.9,0.9]
xsol=[0,0]
ysol=[0,0]

angle_arr  = findgen(width*10)/10 - width/2.

ff=1
Cs=1.5*4
syms = 7



lab_r3 = where(cme_r le 3,nl3)

cme_days3 = findgen(255)*max(cme_t[lab_r3])/255
cme_radius3 = interpol(cme_r[lab_r3],cme_t[lab_r3],cme_days3)



;plot inner system 
; Get the cme plot to overplot
;loadct,0,/silent
plot,xsol,ysol,psym=3,xrange=inner_r,yrange=inner_r,xstyle=5,ystyle=5,position=position
;loadct,5,/silent
      cme_xx = fltarr(255)
      cme_yy = fltarr(255)
      for j=0, n_elements(angle_arr)-1 do begin
         for i=0,n_elements(cme_xx)-1  do begin
            polrec,cme_radius3[i],lon_0+angle_arr[j],cme_x,cme_y,/degrees
            cme_xx[i]=cme_x
            cme_yy[i]=cme_y
         endfor
         color = bytscl(cme_days3)/2 + (255./2.)
         for i=0,n_elements(cme_xx)-2 do plots,[cme_xx[i],cme_xx[i+1]],[cme_yy[i],cme_yy[i+1]],color=color[i],thick=2
      endfor

;;Radial axis at hgi 0º
;polrec,sqrt(total(inner_r^2)),0,xax,yax,/degrees
;plots,[0,xax],[0,yax],color=0

color_bar,cme_days3,.1,0.9,0.87,0.93,/normal,bottom=min(color)+1,color=0,/above,Font=ff, Charsize=cs,title='Days'
foreground = TVREAD(TRUE=3)
; Plot the planets on both times, with fill and not.
;loadct,0,/silent
plot,xsol,ysol,psym=3,xrange=inner_r,yrange=inner_r,xstyle=5,ystyle=5,position=position

;orbits
for i = 0,3 do begin
   pp=plot_orbit(planets[i],/orbit,/over,color=100,thick=5)
endfor
;planets
;set_line_color
circle_sym, thick = 2
for i = 0,3  do begin
   plots,planets[i].start.orbit_x,planets[i].start.orbit_y,psym=8,color=planets_colors[i],symsize=syms
endfor
circle_sym, thick = 2,/fill
for i = 0,3  do begin
   plots,planets[i].hitpos.orbit_x,planets[i].hitpos.orbit_y,psym=8,color=planets_colors[i],symsize=syms
   if planets[i].hitormiss eq 1 then begin
      circle_sym, thick = 3
      plots,planets[i].hitpos.orbit_x,planets[i].hitpos.orbit_y,psym=8,color=100,symsize=syms
      circle_sym, thick = 2,/fill
   endif
endfor
;Plot the sun
 plots, [ 0 , 0 ], [ 0, 0 ], psym = 8, color = 2, symsize = syms+1

;Legend of planets
plots,0.1,0.1,/normal,psym = 8, color = 2, symsize = syms
xyouts, 0.13,0.09, 'Sun',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2
plots,0.3,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.33,0.09, 'Start Time',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2,/fill
plots,0.5,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.53,0.09, 'End Time',color=0,/normal,Font=ff, Charsize=cs
plots,0.1,0.05,/normal,psym = 8, color = planets_colors[0], symsize = syms
xyouts, 0.13,0.04, 'Mercury',color=0,/normal,Font=ff, Charsize=cs
plots,0.3,0.05,/normal,psym = 8, color = planets_colors[1], symsize = syms
xyouts, 0.33,0.04, 'Venus',color=0,/normal,Font=ff, Charsize=cs
plots,0.5,0.05,/normal,psym = 8, color = planets_colors[2], symsize = syms
xyouts, 0.53,0.04, 'Earth',color=0,/normal,Font=ff, Charsize=cs
plots,0.7,0.05,/normal,psym = 8, color = planets_colors[3], symsize = syms
xyouts, 0.73,0.04, 'Mars',color=0,/normal,Font=ff, Charsize=cs


background = TVREAD(TRUE=3)

;** imagemagick way
a = rebin(transpose(foreground,[2,0,1]),3,600,600)
write_png,file_out+'_inner_fg.png',a
a = rebin( transpose(background,[2,0,1]),3,600,600)
write_png,file_out+'_inner_bg.png',a
spawn,'convert '+file_out+'_inner_bg.png -fuzz 05% -transparent white '+file_out+'_inner_bg_tr.png'
spawn,'convert '+file_out+'_inner_fg.png -fuzz 05% -transparent white '+file_out+'_inner_fg_tr.png'
spawn,'composite -dissolve 100 -gravity center '+ file_out+'_inner_bg_tr.png '+file_out+'_inner_fg_tr.png '+file_out+'_inner_b.png'
spawn,'convert '+file_out+'_inner_b.png -background white -flatten '+file_out+'cme_pm_inner.png'
spawn,'rm '+file_out+'_inner_[fg,bg,b]*.png'




lab_r10 = where(cme_r le 50,nl3)

cme_days10 = findgen(255)*max(cme_t[lab_r10])/255
cme_radius10 = interpol(cme_r[lab_r10],cme_t[lab_r10],cme_days10)



;plot inner system 
; Get the cme plot to overplot
;loadct,0,/silent
plot,xsol,ysol,psym=3,xrange=outer_r,yrange=outer_r,xstyle=5,ystyle=5,position=position
;loadct,5,/silent
      cme_xx = fltarr(255)
      cme_yy = fltarr(255)
      for j=0, n_elements(angle_arr)-1 do begin
         for i=0,255-1  do begin
            polrec,cme_radius10[i],lon_0+angle_arr[j],cme_x,cme_y,/degrees
            cme_xx[i]=cme_x
            cme_yy[i]=cme_y
         endfor
         color = bytscl(cme_days10)/2 + (255./2.)
         for i=0,255-2 do plots,[cme_xx[i],cme_xx[i+1]],[cme_yy[i],cme_yy[i+1]],color=color[i],thick=2
      endfor
color_bar,cme_days10,.1,0.9,0.87,0.93,/normal,bottom=min(color)+1,color=0,/above,Font=ff, Charsize=cs,title='Days'
foreground = TVREAD(TRUE=3)
; Plot the planets on both times, with fill and not.
;loadct,0,/silent
plot,xsol,ysol,psym=3,xrange=outer_r,yrange=outer_r,xstyle=5,ystyle=5,position=position

;orbits
for i = 4,8 do begin
   pp=plot_orbit(planets[i],/orbit,/over,color=100,thick=5)
endfor
;planets
;set_line_color
circle_sym, thick = 2
for i = 4,8  do begin
   plots,planets[i].start.orbit_x,planets[i].start.orbit_y,psym=8,color=planets_colors[i],symsize=syms
endfor
circle_sym, thick = 2,/fill
for i = 4,8  do begin
   plots,planets[i].hitpos.orbit_x,planets[i].hitpos.orbit_y,psym=8,color=planets_colors[i],symsize=syms
   if planets[i].hitormiss eq 1 then begin
      circle_sym, thick = 3
      plots,planets[i].hitpos.orbit_x,planets[i].hitpos.orbit_y,psym=8,color=100,symsize=syms
      circle_sym, thick = 2,/fill
   endif
endfor
;Plot the sun
 plots, [ 0 , 0 ], [ 0, 0 ], psym = 8, color = 2, symsize = syms+1

;Legend of planets
plots,0.1,0.1,/normal,psym = 8, color = 2, symsize = syms
xyouts, 0.13,0.09, 'Sun',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2
plots,0.3,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.33,0.09, 'Start Time',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2,/fill
plots,0.5,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.53,0.09, 'End Time',color=0,/normal,Font=ff, Charsize=cs
plots,0.1,0.05,/normal,psym = 8, color = planets_colors[4], symsize = syms
xyouts, 0.13,0.04, 'Jupiter',color=0,/normal,Font=ff, Charsize=cs
plots,0.3,0.05,/normal,psym = 8, color = planets_colors[5], symsize = syms
xyouts, 0.33,0.04, 'Saturn',color=0,/normal,Font=ff, Charsize=cs
plots,0.5,0.05,/normal,psym = 8, color = planets_colors[6], symsize = syms
xyouts, 0.53,0.04, 'Uranus',color=0,/normal,Font=ff, Charsize=cs
plots,0.7,0.05,/normal,psym = 8, color = planets_colors[7], symsize = syms
xyouts, 0.73,0.04, 'Neptune',color=0,/normal,Font=ff, Charsize=cs
plots,0.85,0.05,/normal,psym = 8, color = planets_colors[8], symsize = syms
xyouts, 0.88,0.04, 'Pluto',color=0,/normal,Font=ff, Charsize=cs


background = TVREAD(TRUE=3)

;** imagemagick way
a = rebin(transpose(foreground,[2,0,1]),3,600,600)
write_png,file_out+'_outer_fg.png',a
a = rebin( transpose(background,[2,0,1]),3,600,600)
write_png,file_out+'_outer_bg.png',a
spawn,'convert '+file_out+'_outer_bg.png -fuzz 05% -transparent white '+file_out+'_outer_bg_tr.png'
spawn,'convert '+file_out+'_outer_fg.png -fuzz 05% -transparent white '+file_out+'_outer_fg_tr.png'
spawn,'composite -dissolve 100 -gravity center '+ file_out+'_outer_bg_tr.png '+file_out+'_outer_fg_tr.png '+file_out+'_outer_b.png'
spawn,'convert '+file_out+'_outer_b.png -background white -flatten '+file_out+'cme_pm_outer.png'
spawn,'rm '+file_out+'_outer_[fg,bg,b]*.png'




end


pro web_cme,planets,file_out=file_out
planet_name = ['MERCURY','VENUS','EARTH','MARS','JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']

file_input = file_out+'_input_'
file_output = file_out+'_output_'
file_cxs = file_out+'_cxs_'

t0 = planets[0].inputs.st_time
openw,lun,file_input,/get_lun
  printf,lun,"<li> Start Time <div class='input'>"+planets[0].inputs.st_time+"</div></li>"
  printf,lun,"<li> Longitude <div class='input'>"+string(planets[0].inputs.st_long,format='(F6.2)')+"</div></li>"
  printf,lun,"<li> Width <div class='input'>"+string(planets[0].inputs.width,format='(F6.2)')+"</div></li>"
  printf,lun,"<li> CME speed <div class='input'>"+string(planets[0].inputs.cme_vel,format='(F7.2)') +" &plusmn; "+string(planets[0].inputs.cme_vel_e,format='(F7.2)')+"</div></li>"
  printf,lun,"<li> <a href='http://cagnode58.cs.tcd.ie:8080/PropagationModelGUI/'><button type='button'>Reset</button></a></div></li>"
  printf,lun,"</ul> </div>  <!-- input values -->"
;  printf,lun,"</div><!-- input box -->"
close,/all

openw,lun,file_output,/get_lun
  printf,lun,"	<div class='Result'> <!-- result box -->"
  hits = where(planets.hitormiss eq 1,nhits)
  if nhits eq 0 then begin
     printf,lun," <ul> <li> No Planet is hit </li></ul>"
  endif else begin
     printf,lun," <ul> <li> Output </li></ul>" 
     printf,lun,"    <table>" 
     printf,lun,"     <tr> <th> Planet </th> <th> ETA min</th> <th> ETA max </th> <th> Dt min(days) </th><th> Dt max(days) </th></tr>"
     for i=0,nhits-1 do begin
        t_min = strsplit(planets[hits[i]].minmax_t.t_min,"T",/extract)
        t_max = strsplit(planets[hits[i]].minmax_t.t_max,"T",/extract)
        printf,lun,"     <tr> <td>"+planet_name[planets[hits[i]].n-1]+"</td><td>"+$
                                   t_min[0]+"<br>"+t_min[1]+"</td><td>"+$
                                   t_max[0]+"<br>"+t_max[1]+"</td><td align='center'>"+$
                                   string((anytim(planets[hits[i]].minmax_t.t_min) - anytim(t0))/(3600.*24.),format='(F6.2)')+"</td><td>"+$
                                   string((anytim(planets[hits[i]].minmax_t.t_max) - anytim(t0))/(3600.*24.),format='(F6.2)')+"</td><td>"+$
                   "</td></tr>"
     endfor
     printf,lun,"    </table>" 
     printf,lun,"<div class='download'><a href='./cme_pm.votable'><button type='button'>Download VOTable</button></a></div>"
  endelse
  printf,lun,"   </div> <!-- result box -->"
close,/all

openw,lun,file_cxs ,/get_lun
  printf,lun,"		<div class='links'> <!-- links box -->"
  printf,lun,"	  <ul>"
  date=strsplit(anytim(t0,/ecs,/date),'/',/extract)
  date0=strsplit(anytim(anytim(t0)-(24*3600.),/ecs,/date),'/',/extract)
  date1=strsplit(anytim(anytim(t0)+(24*3600.),/ecs,/date),'/',/extract)
  link_goes = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=00&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=goesplotter&format=html"
  printf,lun,"      <li> <a href='"+link_goes+"'> GOES plotter</a></li>"
  link_flares = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=20&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=flareplotter&format=html"
  printf,lun,"      <li> <a href='"+link_flares+"'> Flare plotter</a></li>"
  
  sm_link = "http://solarmonitor.org/index.php?date="+date[0]+date[1]+date[2]
  printf,lun,"      <li> <a href='"+sm_link+"'> Solar Monitor for "+anytim(t0,/vms,/date)+"</a></li>"

  sw_link = "http://spaceweather.com/archive.php?view=1&day="+date[2]+"&month="+date[1]+"&year="+date[0]
  printf,lun,"      <li> <a href='"+sw_link+"'> Space Weather for "+anytim(t0,/vms,/date)+"</a></li>"

  printf,lun," </ul>"
close,/all

;spawn cat header .... footer > file_out
join_all = 'cat cme_index_header.html '+file_input+' '+file_output+' '+file_cxs +' cme_index_footer.html > '+ file_out
spawn,join_all

;spawn delete midfiles
delete_midfiles = 'rm '+file_input+' '+file_output+' '+file_cxs 
spawn,delete_midfiles
end



pro prop_end,t0=t0,x0=x0,width=width,vel=vel,e_vel=e_vel,PATH_OUT=PATH_OUT

if ~keyword_set(t0) then t0 = anytim(systim(),/ccs) else t0=anytim(t0,/ccs)
if (n_elements(x0) eq 0) then x0=[0]; lon-lat HGI
if (n_elements(width) eq 0) then width=45 ; width in deg
if ~keyword_set(vel) then vel=800 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
if ~keyword_set(path_out) then path_out = '/tmp/'

planet_name = ['MERCURY','VENUS','EARTH','MARS','JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']

x_sol = [x0,0]
for i=1,9 do begin
   cme_prop_sp,planetn=i,x_sol=x_sol,t_sol=t0,cme_vel=vel,dlong=width,planet_out=planet,cme_val=cme,e_vel=e_vel
   planet_all = (i eq 1)?planet:[planet_all,planet]
   cme_all = (i eq 1)?cme:[cme_all,cme]
   delvarx,planet,cme

endfor

ploting_prop,planet_all,cme_all,[long_hgihg(x_sol[0],/hg,date=t0),width],path_out

file_out = path_out+'output'
;writing out the info
openw,lun,file_out+'.out',/get_lun
printf,lun,"#Starting parameters"
printf,lun,'Starting time: '+t0
printf,lun,'Starting longitude: '+string(x0,format='(F6.2)')
printf,lun,'Width: '+string(width,format='(F6.2)')
printf,lun,'Velocity: '+string(vel,format='(F7.2)')
for i=0,8 do begin
   printf,lun,'------------------------------'
   printf,lun,'planet:'+string(planet_all[i].n,format='(I1)')
   printf,lun,'distance:'+string(planet_all[i].start.radio,format='(F7.3)')
   printf,lun,'hit:'+ string(planet_all[i].hitormiss,format='(I1)')
   t1_out = (planet_all[i].hitormiss eq 0)?'0':planet_all[i].hitpos.date
   printf,lun,'eta:'+t1_out
endfor
close,/all

file_out = path_out+'cme_pm'
openw,lun,file_out+'.csv',/get_lun
printf,lun,"time_start,long_hg,long_hci,long_width,v,v_err,target_obj,r_hci,HitOrMiss,ETA,ETA_min,ETA_max,Dt,Dt_min,Dt_max"
start_str = t0 + ',' + $
            string(x0,format='(F6.2)') +',' + $
            string(planet_all[0].inputs.st_long_hci,format='(F7.2)') +',' + $
            string(width,format='(F6.2)') +','+ $
            string(vel,format='(F7.2)') +','+$
            string(e_vel,format='(F7.2)')
for i = 0,8  do begin
   t1_out = (planet_all[i].hitormiss eq 0)?'':planet_all[i].hitpos.date
   t1_out_min = (t1_out eq '')?'':planet_all[i].minmax_t.t_min
   t1_out_max = (t1_out eq '')?'':planet_all[i].minmax_t.t_max
   dt1_out = (t1_out eq '')?'':string((anytim(planet_all[i].hitpos.date) - anytim(t0))/(3600.*24.),format='(F7.2)')
   dt1_out_min = (t1_out eq '')?'':string((anytim(planet_all[i].minmax_t.t_min) - anytim(t0))/(3600.*24.),format='(F7.2)')
   dt1_out_max = (t1_out eq '')?'':string((anytim(planet_all[i].minmax_t.t_max) - anytim(t0))/(3600.*24.),format='(F7.2)')

   rest_str = planet_name[planet_all[i].n-1] + ',' + $ ; Planet
              string(planet_all[i].start.radio,format='(F7.3)') +',' +  $ ; distance
              string(planet_all[i].hitormiss,format='(I1)') +',' +  $ ; HitOrMiss
              t1_out +',' + $                                         ; time to reach earth
              t1_out_min +',' + $                                     ; min time
              t1_out_max   +',' + $                                   ; max time
              dt1_out +',' + $                                        ; days to reach earth
              dt1_out_min +',' + $                                    ; min number of days
              dt1_out_max                                             ; max number of days
   printf,lun,start_str+','+rest_str
endfor
close,/all

stilts_command = './stilts tcopy '+file_out+'.csv ifmt=csv '+file_out+'.votable ofmt=votable'
spawn,stilts_command

set_plot,'x'


web_cme,planet_all,file_out=path_out+'index.html'


end
