function posang,ang
  ang = ang mod 360
  posang = ang
  if ang lt 0 then posang=ang+360
 
return,posang
end

pro setz
  set_plot,'z'
  loadct,0,/silent
  COMBINE_COLORS,/LOWER	
  loadct,5,/silent
  COMBINE_COLORS
  set_line_color
  Device, Set_Resolution=[2400, 2400]
  ;window,15,xsize=600, ysize=600
  !p.background = 255
end
pro plot_prop_part,planets,spacecraft,cme_s,cme_t,cme_r,mini,range,name,file_out 
lon_0 = cme_s[0]
width = cme_s[1]
planets_colors=[9,7,5,3,6,2,4,10,9]
spacecraft_colors=[8,5,3,10,6,4,4,10,5,7]
setz
; Set plot parameters, positions font and sizes
position=[0.1,0.1,0.9,0.9]
xsol=[0,0]
ysol=[0,0]

ff=1
Cs=1.5*4
syms = 7

; Set the dimension of the angle array to plot the wedge
angle_arr  = findgen(width*10)/10 - width/2.

longer_rad = sqrt(total(range^2))
lab_r = where(cme_r le longer_rad,nl)
lab_r_sc = where((spacecraft.pos_t0.radio le longer_rad) and (spacecraft.pos_t0.radio gt mini) ,nscl)
lab_r_pl = where((planets.pos_t0.radio le longer_rad) and (planets.pos_t0.radio gt mini),npll)

cme_days = findgen(255)*max(cme_t[lab_r])/255
cme_radius = interpol(cme_r[lab_r],cme_t[lab_r],cme_days)
;;=======================================================
;;=================== Plot Foreground ===================
plot,xsol,ysol,psym=3,xrange=range,yrange=range,xstyle=5,ystyle=5,position=position
;;=================== Plot the CME =======================
      for j=0, n_elements(angle_arr)-1 do begin
         polrec,cme_radius,lon_0+angle_arr[j],cme_xx,cme_yy,/degrees
         color = bytscl(cme_days)/2 + (255./2.)
         for i=0,n_elements(cme_xx)-2 do plots,[cme_xx[i],cme_xx[i+1]],[cme_yy[i],cme_yy[i+1]],color=color[i],thick=2
      endfor
;;=================== Plot the colour bar for CME ETA ============
color_bar,cme_days,.1,0.9,0.87,0.93,/normal,bottom=min(color)+1,color=0,/above,Font=ff, Charsize=cs,title='Days'

foreground = TVREAD(TRUE=3)

;;=======================================================
;;=================== Plot Planets ======================
; Plot the planets on both times, with fill and not.
;loadct,0,/silent
plot,xsol,ysol,psym=3,xrange=range,yrange=range,xstyle=5,ystyle=5,position=position
;;=================== Plot planets orbits =================
for i = 0,npll-1 do $
   pp=plot_orbit(planets[lab_r_pl[i]],/orbit,/over,color=100,thick=5)
;;=================== Plot planets starting pos ===========
circle_sym, thick = 2
for i = 0,npll-1  do $
   plots,planets[lab_r_pl[i]].pos_t0.orbit_x,planets[lab_r_pl[i]].pos_t0.orbit_y,psym=8,color=planets_colors[lab_r_pl[i]],symsize=syms
;;=================== Plot planets t_hit pos ===========
circle_sym, thick = 2,/fill
for i = 0,npll-1  do begin
   plots,planets[lab_r_pl[i]].pos_thit.orbit_x,planets[lab_r_pl[i]].pos_thit.orbit_y,psym=8,color=planets_colors[planets[lab_r_pl[i]].n-1],symsize=syms
   if planets[lab_r_pl[i]].hitormiss eq 1 then begin  ; plot ring gray so it is seen over the CME
      circle_sym, thick = 3
      plots,planets[lab_r_pl[i]].pos_thit.orbit_x,planets[lab_r_pl[i]].pos_thit.orbit_y,psym=8,color=100,symsize=syms
      circle_sym, thick = 2,/fill
   endif
endfor
;;=================== Plot Sun ======================
 plots, [ 0 , 0 ], [ 0, 0 ], psym = 8, color = 2, symsize = syms+1
;;=================== Legend =========================
;Legend of planets
plots,0.1,0.1,/normal,psym = 8, color = 2, symsize = syms
xyouts, 0.13,0.09, 'Sun',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2
plots,0.3,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.33,0.09, 'Start Time',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2,/fill
plots,0.5,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.53,0.09, 'End Time',color=0,/normal,Font=ff, Charsize=cs

dist=(0.9-0.1)/npll
for i = 0,npll-1  do begin
   plots,0.1+i*dist,0.05,/normal,psym = 8, color = planets_colors[planets[lab_r_pl[i]].n-1], symsize = syms
   xyouts,0.13+i*dist,0.04,planets[lab_r_pl[i]].name,color=0,/normal,Font=ff, Charsize=cs
endfor

;;=================== Plot s/c              ===========
if nscl gt 0 then begin
;;=================== Plot s/c starting pos ===========
   dist=(nscl le 3)?0.05:(0.7-0.45)/nscl
   for i = 0,nscl-1  do begin
      scsym, 1.5,thick = 5,rot=posang(90+posang(spacecraft[lab_r_sc[i]].pos_t0.lon))
      plots,spacecraft[lab_r_sc[i]].pos_t0.orbit_x,spacecraft[lab_r_sc[i]].pos_t0.orbit_y,psym=8,color=spacecraft_colors[lab_r_sc[i]],symsize=syms
      scsym, 1.5,thick = 5
      plots,0.03,0.7-i*dist,/normal,psym=8,color=spacecraft_colors[lab_r_sc[i]],symsize=syms
      xyouts,0.052,(0.7-i*dist)-0.01,spacecraft[lab_r_sc[i]].name,/normal,color=0,Font=ff,charsize=cs
   endfor

endif
background = TVREAD(TRUE=3)

;;=================== Save images and merge into one ======================
;;=============== ImageMagik way ==========================================
a = rebin(transpose(foreground,[2,0,1]),3,600,600)
write_png,file_out+'_'+name+'_fg.png',a
a = rebin( transpose(background,[2,0,1]),3,600,600)
write_png,file_out+'_'+name+'_bg.png',a
spawn,'convert '+file_out+'_'+name+'_bg.png -fuzz 05% -transparent white '+file_out+'_'+name+'_bg_tr.png'
spawn,'convert '+file_out+'_'+name+'_fg.png -fuzz 05% -transparent white '+file_out+'_'+name+'_fg_tr.png'
spawn,'composite -dissolve 100 -gravity center '+ file_out+'_'+name+'_bg_tr.png '+file_out+'_'+name+'_fg_tr.png '+file_out+'_'+name+'_b.png'
spawn,'convert '+file_out+'_'+name+'_b.png -background white -flatten '+file_out+'cme_pm_'+name+'.png'
spawn,'rm '+file_out+'_'+name+'_[fg,bg,b]*.png'


end

pro ploting_prop,planets,spacecraft,cme,cme_s,file_out
;print,'lon_0 = '+string(lon_0)
inner_r = [-2.5,2.5]
outer_r = [-46.5,46.5]

cme_t = 0
cme_r = 0
for i=0,(n_elements(cme)/2)-1 do begin
   cme_t =[cme_t,cme[(i*2)]]
   cme_r =[cme_r,cme[(i*2)+1]]
endfor

plot_prop_part,planets,spacecraft,cme_s,cme_t,cme_r,0,inner_r,'inner',file_out

plot_prop_part,planets,spacecraft,cme_s,cme_t,cme_r,sqrt(total(inner_r^2)),outer_r,'outer',file_out

plot_prop_part,planets,spacecraft,cme_s,cme_t,cme_r,30,[-100,100],'voyag',file_out

end
