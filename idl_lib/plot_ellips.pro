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
pro plot_ellips,ellip,over=over,zero=zero,coord=coord,ninety=ninety,_extra=_extra

  plot_command =(~keyword_set(over))?'plot,xrange=xrange,yrange=yrange':'oplot'

  phi = dindgen(101)*2D*!dpi/100
  xm = ellip[2] + ellip[0]*cos(phi)*cos(ellip[4]) + ellip[1]*sin(phi)*sin(ellip[4])
  ym = ellip[3] - ellip[0]*cos(phi)*sin(ellip[4]) + ellip[1]*sin(phi)*cos(ellip[4])
  a=execute(plot_command+',xm,ym,_extra=_extra')
  if keyword_set(zero) then oplot,[0,xm[0]],[0,ym[0]]
  if keyword_set(ninety) then oplot,[0,xm[(sort(abs(phi-!pi/2.)))[0]]],[0,ym[(sort(abs(phi-!pi/2.)))[0]]]

end




end
