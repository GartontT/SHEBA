function posang,ang
  ang = ang mod 360
  posang = ang
  if ang lt 0 then posang=ang+360
return,posang
end
;; function plot_sep,sep_str,_extra=_extra
;; ;;=================== Plot Sun ===================
;; plot,[0,0],[0,0],psym=3,_extra=_extra

;; rot_sun =  14.4 
;; vel_wind = sep_str.vel +[-1,1]*sep_str.e_vel
;; sw_lon = sep_str.long_hci

;; ;; Define solar wind spiral
;; v_plot = (vel_wind[1] eq vel_wind[0])?vel_wind[0]:findgen(fix(vel_wind[1]-vel_wind[0]))+vel_wind[0]
;; v_au_plot =  ( v_plot / 150e6 ) * 24. * 60. * 60.
;; theta_sp = -findgen( 360 * 6. )                  ;
;; r_plot = -( v_au_plot / rot_sun ) # theta_sp ; 2 dimension [(vel-e,vel+e),radius]
;; theta_spiral = theta_sp + sw_lon
;; for i=0,n_elements(v_plot)-1 do begin
;;    polrec,r_plot[i,*],theta_spiral,spir_x,spir_y,/degrees
;;    oplot,spir_x,spir_y,color=150 ;,thick=1
;; endfor




;; return,foreground
;; end
function plot_cme,cme_str,longer_rad=longer_rad,bar_font=bar_font,bar_charsize=bar_charsize,_extra=_extra
;;=================== Plot Sun ===================
plot,[0,0],[0,0],psym=3,_extra=_extra

; Set the dimension of the angle array to plot the wedge
angle_arr  = findgen(cme_str.width*10)/10 - cme_str.width/2.

lab_r = where(cme_str.cme_r le longer_rad,nl)
cme_days = findgen(255)*max(cme_str.cme_t[lab_r])/255
cme_radius = interpol(cme_str.cme_r[lab_r],cme_str.cme_t[lab_r],cme_days)

;;=================== Plot the CME =======================
      for j=0, n_elements(angle_arr)-1 do begin
         polrec,cme_radius,cme_str.lon+angle_arr[j],cme_xx,cme_yy,/degrees
         color = bytscl(cme_days)/2 + (255./2.)
         for i=0,n_elements(cme_xx)-2 do plots,[cme_xx[i],cme_xx[i+1]],[cme_yy[i],cme_yy[i+1]],color=color[i],thick=2
      endfor
;;=================== Plot the colour bar for CME ETA ============
color_bar,cme_days,.1,0.9,0.87,0.93,/normal,bottom=min(color)+1,color=0,/above,title='Days',font=bar_font,charsize=bar_charsize

foreground = TVREAD(TRUE=3)
return,foreground
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
pro plot_prop_part,planets,spacecraft,mini,range,name,file_out,cme_str=cme_str
planets_colors=[9,7,5,3,6,2,4,10,9]
spacecraft_colors=[8,5,3,10,6,4,4,10,5,7,3]

setz   ;TODO: Unsetz

; Set plot parameters, positions font and sizes
position=[0.1,0.1,0.9,0.9]
xsol=[0,0]
ysol=[0,0]

ff=1
Cs=1.5*4
syms = 7

; Set properties general plot (planets, s/c,..)
longer_rad = sqrt(total(range^2))
lab_r_pl = where((planets.pos_t0.radio le longer_rad) and (planets.pos_t0.radio gt mini),npll)

if data_chk(cme_str,/type) eq 8 then $
   foreground = plot_cme(cme_str,longer_rad=longer_rad,xrange=range,yrange=range,xstyle=5,ystyle=5,position=position,bar_Font=ff, bar_Charsize=cs)


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
if data_chk(spacecraft,/type) eq 8 then begin
   lab_r_sc = where((spacecraft.pos_t0.radio le longer_rad) and (spacecraft.pos_t0.radio gt mini) ,nscl)
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

pro ploting_prop,planets,spacecraft,file_out,plot_cme=plot_cme,cme_val=cme_val,cme_s=cme_s
;print,'lon_0 = '+string(lon_0)
inner_r = [-2.5,2.5]
outer_r = [-46.5,46.5]

if keyword_set(plot_cme) then begin
   lab_t = indgen(n_elements(cme_val)/2)*2
   lab_r = indgen(n_elements(cme_val)/2)*2+1
   cme_t = cme_val[lab_t]
   cme_r = cme_val[lab_r]
   cme_str = {lon:cme_s[0], width:cme_s[1],cme_r:cme_r, cme_t:cme_t}
endif
;; if keyword_set(plot_sep) then begin
;;    planet_hit = where(planets.hit.hitormiss eq 1,nplhit)
;;    spacecrfat_hit = where(spacecraft.hit.hitormiss eq 1, nschit)
;;    sep_v = planets[planet_hit].hit.swvel * (24. * 60. * 60.) / 150e6
;;    sep_r = planets[planet_hit].hit.r_spiral
;;    sep_th = planets[planet_hit].hit.th_spiral
;;    sep_lon =
;;    cme_t = cme_val[lab_t]
;;    cme_r = cme_val[lab_r]
;;    cme_str = {lon:cme_s[0], width:cme_s[1],cme_r:cme_r, cme_t:cme_t}
;; endif

plot_prop_part,planets,spacecraft,0,inner_r,'inner',file_out,cme_str=cme_str
plot_prop_part,planets,spacecraft,sqrt(total(inner_r^2)),outer_r,'outer',file_out,cme_str=cme_str
plot_prop_part,planets,spacecraft,30,[-100,100],'voyag',file_out,cme_str=cme_str

end
