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