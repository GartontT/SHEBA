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
pro prop_muck,t0=t0,x0=x0,width=width,vel=vel,FILE_OUT = FILE_OUT

if ~keyword_set(t0) then t0 = systim()
if ~keyword_set(x0) then x0=[0]; lon-lat HGI
if ~keyword_set(width) then width=45 ; width in deg
if ~keyword_set(vel) then vel=800 ;km/s
if ~keyword_set(file_out) then file_out = '/tmp/prop_'+string(strcompress(t0,/remove_all))

openw,lun,file_out+'.out',/get_lun
aa = randomn(3,1000)
j = 0
set_plot,'z'
xsol=[0,0]
ysol=[0,0]
plot,xsol,ysol,psym=3,xrange=[-3,3],yrange=[-3,3],xstyle=1,ystyle=1
for i=1,4 do begin
   printf,lun,'------------------------------'
   jd_struct = anytim2jd(t0)
   jd = jd_struct.int + jd_struct.frac
   helio, jd, i, planet_t0_rad, planet_t0_lon, planet_t0_lat
   polrec,planet_t0_rad, planet_t0_lon, xxp,yyp,/degrees
   plots,xxp,yyp,psym=4
   t1 = anytim(anytim(t0)+i*aa[j]*10000.,/yohkoh)
   xyouts,xxp,yyp,t1
   hit = round(aa[j+i])
   printf,lun,'planet:'+string(i,format='(I1)')
   printf,lun,'hit:'+ string(hit,format='(I1)')
   t1_out = (hit eq 0)?'0':t1
   printf,lun,'eta:'+t1_out
   j = j+aa[j]*10
endfor
polrec,4,x0,xx,yy
oplot,[0,xx],[0,yy]

close,/all

a = tvread(/true)
a = transpose(a,[2,0,1])
write_png,file_out+'.png',a

set_plot,'x'
end
